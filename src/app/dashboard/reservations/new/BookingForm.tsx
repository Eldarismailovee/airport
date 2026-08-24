'use client';

import { useActionState } from 'react';
import { createBooking, type ActionResponse } from './actions';
import { FormPartnerOption } from './page';

import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

interface BookingFormProps {
  partners: FormPartnerOption[];
  isPartner: boolean;
}

const initialState: ActionResponse = {
  success: false,
  error: '',
  fieldErrors: {},
};

export default function BookingForm({ partners, isPartner }: BookingFormProps) {
  const [state, formAction, isPending] = useActionState(createBooking, initialState);

  return (
    <Card className="border-muted/40 shadow-md">
      <CardContent className="p-6">
        <form action={formAction} className="space-y-6">
          
          {state.error && (
            <div className="p-3 text-sm font-medium bg-destructive/10 text-destructive rounded-lg border border-destructive/20">
              {state.error}
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            
            {/* Аэропорт локации (Обязательное поле по схеме Prisma) */}
            <div className="space-y-2">
            <Label htmlFor="locationAirport">Аэропорт локации</Label>
            <Input
                type="text"
                id="locationAirport"
                name="locationAirport"
                required
                placeholder="например, DXB"
                className={state.fieldErrors?.locationAirport ? 'border-destructive' : ''}
            />
            {state.fieldErrors?.locationAirport && (
                <p className="text-xs font-medium text-destructive">{state.fieldErrors.locationAirport}</p>
            )}
            </div>
            {/* Выбор партнёра (только для админов) */}
            {!isPartner ? (
              <div className="space-y-2">
                <Label htmlFor="partnerId">Партнёр</Label>
                <Select name="partnerId" required>
                  <SelectTrigger id="partnerId" className={state.fieldErrors?.partnerId ? 'border-destructive' : ''}>
                    <SelectValue placeholder="Выберите партнёра" />
                  </SelectTrigger>
                  <SelectContent>
                    {partners.map((p) => (
                      <SelectItem key={p.id} value={p.id}>
                        {p.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {state.fieldErrors?.partnerId && (
                  <p className="text-xs font-medium text-destructive">{state.fieldErrors.partnerId}</p>
                )}
              </div>
            ) : (
              <input type="hidden" name="partnerId" value="00000000-0000-0000-0000-000000000000" />
            )}

            {/* Аэропорт локации (Обязательное поле по схеме) */}
            <div className="space-y-2">
              <Label htmlFor="locationAirport">Аэропорт локации</Label>
              <Input
                type="text"
                id="locationAirport"
                name="locationAirport"
                required
                placeholder="например, DXB"
                className={state.fieldErrors?.locationAirport ? 'border-destructive' : ''}
              />
              {state.fieldErrors?.locationAirport && (
                <p className="text-xs font-medium text-destructive">{state.fieldErrors.locationAirport}</p>
              )}
            </div>

            {/* Дата и время забора */}
            <div className="space-y-2">
              <Label htmlFor="pickupDateTime">Дата и время забора</Label>
              <Input
                type="datetime-local"
                id="pickupDateTime"
                name="pickupDateTime"
                required
                className={state.fieldErrors?.pickupDateTime ? 'border-destructive' : ''}
              />
              {state.fieldErrors?.pickupDateTime && (
                <p className="text-xs font-medium text-destructive">{state.fieldErrors.pickupDateTime}</p>
              )}
            </div>

            {/* Дата и время возврата */}
            <div className="space-y-2">
              <Label htmlFor="returnDateTime">Дата и время возврата</Label>
              <Input
                type="datetime-local"
                id="returnDateTime"
                name="returnDateTime"
                required
                className={state.fieldErrors?.returnDateTime ? 'border-destructive' : ''}
              />
              {state.fieldErrors?.returnDateTime && (
                <p className="text-xs font-medium text-destructive">{state.fieldErrors.returnDateTime}</p>
              )}
            </div>

            {/* Категория кресла */}
            <div className="space-y-2">
              <Label htmlFor="seatCategory">Категория кресла</Label>
              <Select name="seatCategory" required>
                <SelectTrigger id="seatCategory" className={state.fieldErrors?.seatCategory ? 'border-destructive' : ''}>
                  <SelectValue placeholder="Выберите категорию" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="INFANT_CARRIER">Автолюлька</SelectItem>
                  <SelectItem value="INFANT">Младенческое кресло</SelectItem>
                  <SelectItem value="TODDLER">Кресло для малышей</SelectItem>
                  <SelectItem value="BOOSTER">Бустер</SelectItem>
                  <SelectItem value="STROLLER_LIGHT">Лёгкая коляска</SelectItem>
                  <SelectItem value="STROLLER_RECON">Тяжёлая коляска</SelectItem>
                </SelectContent>
              </Select>
              {state.fieldErrors?.seatCategory && (
                <p className="text-xs font-medium text-destructive">{state.fieldErrors.seatCategory}</p>
              )}
            </div>

            {/* Возрастная группа */}
            <div className="space-y-2">
              <Label htmlFor="childAgeBand">Возрастная группа</Label>
              <Select name="childAgeBand">
                <SelectTrigger id="childAgeBand">
                  <SelectValue placeholder="Не указано" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="NONE">Не указано</SelectItem>
                  <SelectItem value="NEWBORN_0_3M">Новорождённые (0-3 мес)</SelectItem>
                  <SelectItem value="INFANT_0_1">Младенцы (0-1 год)</SelectItem>
                  <SelectItem value="TODDLER_1_4">Малыши (1-4 года)</SelectItem>
                  <SelectItem value="CHILD_4_12">Дети (4-12 лет)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Рост ребёнка */}
            <div className="space-y-2">
              <Label htmlFor="childHeight">Рост ребёнка (см)</Label>
              <Input type="text" id="childHeight" name="childHeight" placeholder="Например, 95" />
            </div>

            {/* Автомобиль */}
            <div className="space-y-2">
              <Label htmlFor="vehicle">Автомобиль</Label>
              <Input type="text" id="vehicle" name="vehicle" placeholder="Toyota Camry" />
            </div>

            {/* Место выдачи (Bay) */}
            <div className="space-y-2">
              <Label htmlFor="vehicleBay">Место выдачи (Bay)</Label>
              <Input type="text" id="vehicleBay" name="vehicleBay" placeholder="A-12" />
            </div>

            {/* Номер рейса */}
            <div className="space-y-2">
              <Label htmlFor="flightNumber">Номер рейса</Label>
              <Input type="text" id="flightNumber" name="flightNumber" placeholder="SU-2130" />
            </div>

            {/* Дневная ставка */}
            <div className="space-y-2">
              <Label htmlFor="dailyRate">Дневная ставка ($)</Label>
              <Input
                type="number"
                step="0.01"
                id="dailyRate"
                name="dailyRate"
                required
                className={state.fieldErrors?.dailyRate ? 'border-destructive' : ''}
                placeholder="15.00"
              />
              {state.fieldErrors?.dailyRate && (
                <p className="text-xs font-medium text-destructive">{state.fieldErrors.dailyRate}</p>
              )}
            </div>

            {/* Внешний номер брони */}
            <div className="grid grid-cols-1 col-span-1 md:col-span-2 space-y-2">
              <Label htmlFor="externalBookingNumber">Внешний номер бронирования</Label>
              <Input type="text" id="externalBookingNumber" name="externalBookingNumber" placeholder="EXT-99821" />
            </div>

          </div>

          <Button type="submit" disabled={isPending} className="w-full mt-4">
            {isPending ? 'Создание бронирования...' : 'Создать бронирование'}
          </Button>

        </form>
      </CardContent>
    </Card>
  );
}
