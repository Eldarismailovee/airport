'use client';

import { useActionState } from 'react';
import { useSearchParams } from 'next/navigation';
import { login } from './actions';

const initialState = { error: '' };

export default function LoginPage() {
  const searchParams = useSearchParams();
  const redirectedFrom = searchParams.get('redirectedFrom') || '';
  const [state, formAction, isPending] = useActionState(login, initialState);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <form action={formAction} className="bg-white p-8 rounded-lg shadow-md w-full max-w-sm space-y-4">
        <h1 className="text-2xl font-bold text-center">Вход в систему</h1>
        {state.error && <div className="text-red-500 text-sm">{state.error}</div>}

        {/* Скрытое поле для возврата на исходную страницу */}
        <input type="hidden" name="redirectedFrom" value={redirectedFrom} />

        <input
          type="email"
          name="email"
          placeholder="Email"
          className="w-full border rounded-md px-3 py-2"
          required
        />
        <input
          type="password"
          name="password"
          placeholder="Пароль"
          className="w-full border rounded-md px-3 py-2"
          required
        />
        <button
          type="submit"
          disabled={isPending}
          className="w-full bg-blue-600 text-white rounded-md py-2 hover:bg-blue-700 disabled:bg-slate-400"
        >
          {isPending ? 'Входим...' : 'Войти'}
        </button>
      </form>
    </div>
  );
}