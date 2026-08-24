'use server';

import { z } from 'zod';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import prisma from '@/lib/prisma';
import { createClient } from '@/utils/supabase/server';
import { BookingStatus, SeatCategory, ChildAgeBand, Prisma } from '@prisma/client';

const bookingSchema = z.object({
  partnerId: z.string().uuid('Неверный формат идентификатора партнера'),
  locationAirport: z.string().min(1, 'Укажите аэропорт локации'),
  pickupDateTime: z.string().min(1, 'Дата начала обязательна'),
  returnDateTime: z.string().min(1, 'Дата окончания обязательна'),
  seatCategory: z.nativeEnum(SeatCategory),
  childAgeBand: z.nativeEnum(ChildAgeBand).optional(),
  childHeight: z.string().optional(),
  vehicle: z.string().optional(),
  vehicleBay: z.string().optional(),
  flightNumber: z.string().optional(),
  dailyRate: z.coerce.number().positive('Ставка должна быть больше нуля'),
  externalBookingNumber: z.string().optional(),
});

export type ActionResponse = {
  success: boolean;
  error?: string;
  fieldErrors?: Record<string, string[]>;
};

export async function createBooking(prevState: any, formData: FormData): Promise<ActionResponse> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const profile = await prisma.userProfile.findUnique({
    where: { userId: user.id },
    select: { role: true, partnerId: true }
  });

  if (!profile) redirect('/login');

  const allowedRoles = ['SUPER_ADMIN', 'OPS_MANAGER', 'PARTNER_ADMIN'];
  if (!allowedRoles.includes(profile.role)) {
    return { success: false, error: 'Недостаточно прав для выполнения операции' };
  }

  let targetPartnerId = formData.get('partnerId') as string;
  
  if (profile.role === 'PARTNER_ADMIN') {
    if (!profile.partnerId) {
      return { success: false, error: 'К вашему профилю не привязан аккаунт партнера' };
    }
    targetPartnerId = profile.partnerId;
  }

  const rawChildAgeBand = formData.get('childAgeBand');
  const childAgeBand = rawChildAgeBand && rawChildAgeBand !== 'NONE' ? rawChildAgeBand : undefined;

  const rawData = {
    partnerId: targetPartnerId,
    locationAirport: formData.get('locationAirport'),
    pickupDateTime: formData.get('pickupDateTime'),
    returnDateTime: formData.get('returnDateTime'),
    seatCategory: formData.get('seatCategory'),
    childAgeBand: childAgeBand,
    childHeight: formData.get('childHeight') || undefined,
    vehicle: formData.get('vehicle') || undefined,
    vehicleBay: formData.get('vehicleBay') || undefined,
    flightNumber: formData.get('flightNumber') || undefined,
    dailyRate: formData.get('dailyRate'),
    externalBookingNumber: formData.get('externalBookingNumber') || undefined,
  };

  const validation = bookingSchema.safeParse(rawData);

  if (!validation.success) {
    return { 
      success: false, 
      error: 'Ошибка валидации данных',
      fieldErrors: validation.error.flatten().fieldErrors
    };
  }

  const { data } = validation;

  // 1. Вычисляем количество оплачиваемых дней (минимум 1 день)
  const pickup = new Date(data.pickupDateTime);
  const dropoff = new Date(data.returnDateTime);
  const diffTime = Math.abs(dropoff.getTime() - pickup.getTime());
  const paidDays = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));

  try {
    // 2. Получаем финансовые настройки партнера для автоматического расчета долей
    const settings = await prisma.partnerSettings.findUnique({
      where: { partnerId: data.partnerId },
    });

    // Определяем процентную ставку партнера (проверяем промо-период запуска launchEnabled)
    const partnerSharePct = settings 
      ? (settings.launchEnabled ? settings.launchPartnerShare : settings.defaultPartnerShare) 
      : new Prisma.Decimal(0.30); // 30% дефолт, если настройки не заданы

    // 3. Вычисляем финансовые показатели
    const grossRevenue = new Prisma.Decimal(data.dailyRate).mul(paidDays);
    const partnerShare = grossRevenue.mul(partnerSharePct);
    const platformShare = grossRevenue.sub(partnerShare);

    // 4. Выполняем безопасную транзакцию создания записи
    await prisma.$transaction(async (tx) => {
      await tx.booking.create({
        data: {
          partnerId: data.partnerId,
          locationAirport: data.locationAirport,
          pickupDateTime: pickup,
          returnDateTime: dropoff,
          seatCategory: data.seatCategory,
          childAgeBand: data.childAgeBand,
          childHeight: data.childHeight,
          vehicle: data.vehicle,
          vehicleBay: data.vehicleBay,
          flightNumber: data.flightNumber,
          dailyRate: new Prisma.Decimal(data.dailyRate),
          paidDays: paidDays,
          grossRevenue: grossRevenue,
          partnerShare: partnerShare,
          platformShare: platformShare,
          status: BookingStatus.NEW,
        },
      });
    });

  } catch (dbError) {
    console.error('Database Transaction Error [createBooking]:', dbError);
    return { success: false, error: 'Ошибка сохранения бронирования и финансовых долей' };
  }

  revalidatePath('/reservations');
  redirect('/reservations');
}
