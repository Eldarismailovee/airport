'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';

export async function login(prevState: any, formData: FormData) {
  const supabase = await createClient();

  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/', 'layout');

  // Куда вернуть пользователя после логина
  const redirectedFrom = formData.get('redirectedFrom') as string | null;
  const safeRedirect = redirectedFrom && redirectedFrom.startsWith('/') ? redirectedFrom : '/dashboard';

  redirect(safeRedirect);
}