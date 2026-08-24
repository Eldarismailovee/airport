import { createClient } from '@/utils/supabase/server';
import prisma from '@/lib/prisma';
import { redirect } from 'next/navigation';
import BookingForm from './BookingForm';

// Описываем строгий тип для передачи данных в клиентскую форму
export type FormPartnerOption = {
  id: string;
  name: string;
};

export default async function NewReservationPage() {
  // 1. Инициализация Supabase сессии
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  // 2. Безопасный запрос: вытягиваем ТОЛЬКО роль и partnerId (Защита данных + Скорость)
  const profile = await prisma.userProfile.findUnique({
    where: { userId: user.id },
    select: { 
      role: true,
      partnerId: true 
    }
  });

  if (!profile) redirect('/login');

  // 3. Быстрая проверка прав доступа
  const allowedRoles = ['SUPER_ADMIN', 'OPS_MANAGER', 'PARTNER_ADMIN'];
  if (!allowedRoles.includes(profile.role)) {
    redirect('/reservations');
  }

  // 4. Загрузка партнеров с фильтрацией полей на уровне базы данных (select вместо map)
  let partners: FormPartnerOption[] = [];
  
  if (profile.role === 'SUPER_ADMIN' || profile.role === 'OPS_MANAGER') {
    partners = await prisma.partner.findMany({
      select: {
        id: true,
        name: true
      },
      orderBy: { name: 'asc' }
    });
  }

  return (
    <div className="p-6 max-w-2xl mx-auto space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Новое бронирование</h1>
        <p className="text-sm text-muted-foreground mt-1">
          Заполните форму для создания новой аренды в системе.
        </p>
      </div>
      
      {/* Передаем чистые, отфильтрованные на уровне БД данные */}
      <BookingForm
        partners={partners}
        isPartner={profile.role === 'PARTNER_ADMIN'}
      />
    </div>
  );
}
