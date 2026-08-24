import { createClient } from '@/utils/supabase/server';
import prisma from '@/lib/prisma';
import { redirect } from 'next/navigation';
import { BookingStatus, Prisma } from '@prisma/client';

// 1. Создаем строгий тип для сериализованных данных бэкенда с учетом реальной схемы
type SerializedBooking = Omit<
  Prisma.BookingGetPayload<{
    include: {
      partner: true;
      assignedSeat: true;
      assignedTechnician: true; // Исправлено: UserProfile запрашивается напрямую
      flightStatus: true;
    };
  }>,
  'pickupDateTime' | 'returnDateTime' | 'createdAt' | 'updatedAt' | 'dailyRate' | 'grossRevenue' | 'partnerShare' | 'platformShare'
> & {
  pickupDateTime: string;
  returnDateTime: string;
  createdAt: string;
  updatedAt: string;
  // Поля Decimal из Prisma приходят как объекты, сериализуем их в строки или числа для фронтенда
  dailyRate: string;
  grossRevenue: string;
  partnerShare: string;
  platformShare: string;
};

export default async function ReservationsPage() {
  // 2. Инициализация Supabase
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  // 3. Получаем профиль одной выборкой
  const profile = await prisma.userProfile.findUnique({
    where: { userId: user.id },
    select: { role: true, partnerId: true }
  });

  if (!profile) redirect('/login');

  const isAdmin = ['SUPER_ADMIN', 'OPS_MANAGER'].includes(profile.role);
  const isPartner = profile.role === 'PARTNER_ADMIN';

  // 4. Исправленный объект include в соответствии с вашей schema.prisma
  const commonInclude = {
    partner: true,
    assignedSeat: true,
    assignedTechnician: true, // Просто подтягиваем профиль назначенного техника
    flightStatus: true,
  };

  let bookings: Prisma.BookingGetPayload<{ include: typeof commonInclude }>[] = [];

  if (isAdmin) {
    bookings = await prisma.booking.findMany({
      include: commonInclude,
      orderBy: { pickupDateTime: 'desc' },
    });
  } else if (isPartner && profile.partnerId) {
    bookings = await prisma.booking.findMany({
      where: { partnerId: profile.partnerId },
      include: commonInclude,
      orderBy: { pickupDateTime: 'desc' },
    });
  }

  // 5. Типизированная сериализация с безопасным форматированием дат и Decimal полей
  const serialized: SerializedBooking[] = bookings.map((b) => ({
    ...b,
    pickupDateTime: b.pickupDateTime.toISOString(),
    returnDateTime: b.returnDateTime.toISOString(),
    createdAt: b.createdAt.toISOString(),
    updatedAt: b.updatedAt.toISOString(),
    dailyRate: b.dailyRate.toString(),
    grossRevenue: b.grossRevenue.toString(),
    partnerShare: b.partnerShare.toString(),
    platformShare: b.platformShare.toString(),
  }));

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Бронирования</h1>
        <a href="/dashboard/reservations/new" className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
          + Новое бронирование
        </a>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Партнёр</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Забор</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Категория</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Кресло</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Статус</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Рейс</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {serialized.map((b) => (
              <tr key={b.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm font-mono">{b.id.slice(0,8)}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">{b.partner?.name ?? '—'}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">
                  {new Date(b.pickupDateTime).toLocaleString('ru-RU', { dateStyle: 'short', timeStyle: 'short' })}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">{b.seatCategory}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">{b.assignedSeat?.publicToken ?? '—'}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 text-xs rounded-full font-medium ${
                    b.status === BookingStatus.ACTIVE_RENTAL ? 'bg-green-100 text-green-800' :
                    b.status === BookingStatus.CANCELLED ? 'bg-red-100 text-red-800' :
                    'bg-blue-100 text-blue-800'
                  }`}>
                    {b.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">{b.flightStatus?.flightNumber ?? b.flightNumber ?? '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
