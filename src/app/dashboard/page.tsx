import { createClient } from '@/utils/supabase/server';
import prisma from '@/lib/prisma';
import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  // Защита от гонки: создаём профиль, если его нет
  let profile = await prisma.userProfile.findUnique({
    where: { userId: user.id },
  });

  if (!profile) {
    try {
      profile = await prisma.userProfile.create({
        data: {
          userId: user.id,
          role: 'PASSENGER',
        },
      });
    } catch (error) {
      console.error('Ошибка создания профиля:', error);
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
          <div className="bg-white p-6 rounded-lg shadow-md max-w-md text-center border border-red-200">
            <h2 className="text-xl font-bold text-red-600 mb-2">Ошибка инициализации</h2>
            <p className="text-gray-600">Не удалось создать ваш профиль. Обновите страницу или обратитесь в поддержку.</p>
          </div>
        </div>
      );
    }
  }

  // Инлайн Server Action для выхода
  async function handleSignOut() {
    'use server';
    const supabase = await createClient();
    await supabase.auth.signOut();
    revalidatePath('/', 'layout');
    redirect('/login');
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-4xl mx-auto bg-white rounded-xl shadow-sm p-8 border border-gray-100">
        <header className="flex justify-between items-center border-b pb-4 mb-6">
          <div>
            <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">
              Панель управления
            </h1>
            <p className="text-gray-500 mt-1">Добро пожаловать в систему</p>
          </div>
          <form action={handleSignOut}>
            <button
              type="submit"
              className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition"
            >
              Выйти
            </button>
          </form>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-blue-50/50 p-5 rounded-lg border border-blue-100">
            <span className="text-xs font-semibold uppercase tracking-wider text-blue-600 block mb-1">
              Авторизован как
            </span>
            <strong className="text-lg text-gray-800 font-medium block truncate">
              {user.email}
            </strong>
          </div>

          <div className="bg-purple-50/50 p-5 rounded-lg border border-purple-100">
            <span className="text-xs font-semibold uppercase tracking-wider text-purple-600 block mb-1">
              Уровень доступа (Роль)
            </span>
            <strong className="text-lg text-gray-800 font-medium block">
              {profile.role}
            </strong>
          </div>
        </div>
      </div>
    </div>
  );
}