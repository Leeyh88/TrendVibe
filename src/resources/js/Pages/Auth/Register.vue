<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

const form = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
});

const submit = () => {
    form.post(route('register'), {
        onFinish: () => form.reset('password', 'password_confirmation'),
    });
};
</script>

<template>
    <GuestLayout>
        <Head title="Create Account" />

        <div class="mb-10 text-center">
            <div class="mb-6 inline-flex items-center justify-center">
                <div class="relative mt-6">
                    <div class="absolute inset-0 bg-indigo-500 blur-2xl opacity-20 animate-pulse"></div>
                    <Link href="/" class="inline-block">
                        <span class="text-3xl font-black text-gray-900 group-hover:text-indigo-600 transition-all duration-300">
                            trend<span class="text-indigo-600 group-hover:text-gray-900">Vibe</span>
                        </span>
                        <span class="ml-1 w-1.5 h-1.5 bg-indigo-600 rounded-full animate-pulse"></span>
                    </Link>
                </div>
            </div>
            <p class="text-gray-400 font-bold text-[10px] uppercase tracking-[0.2em] mt-3">Join the community of trend mixers</p>
        </div>

        <form @submit.prevent="submit" class="space-y-5">
            <div>
                <InputLabel for="name" value="User Name" class="text-[10px] font-black text-gray-400 tracking-widest ml-1 mb-2 uppercase" />
                <TextInput
                    id="name"
                    type="text"
                    class="block w-full px-5 py-3.5 bg-gray-50 border-none rounded-2xl text-sm font-bold focus:ring-2 focus:ring-indigo-600 transition-all"
                    v-model="form.name"
                    required
                    autofocus
                    placeholder="Your Stage Name"
                    autocomplete="name"
                />
                <InputError class="mt-2 ml-1" :message="form.errors.name" />
            </div>

            <div>
                <InputLabel for="email" value="Email Address" class="text-[10px] font-black text-gray-400 tracking-widest ml-1 mb-2 uppercase" />
                <TextInput
                    id="email"
                    type="email"
                    class="block w-full px-5 py-3.5 bg-gray-50 border-none rounded-2xl text-sm font-bold focus:ring-2 focus:ring-indigo-600 transition-all"
                    v-model="form.email"
                    required
                    placeholder="email@example.com"
                    autocomplete="username"
                />
                <InputError class="mt-2 ml-1" :message="form.errors.email" />
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <InputLabel for="password" value="Password" class="text-[10px] font-black text-gray-400 tracking-widest ml-1 mb-2 uppercase" />
                    <TextInput
                        id="password"
                        type="password"
                        class="block w-full px-5 py-3.5 bg-gray-50 border-none rounded-2xl text-sm font-bold focus:ring-2 focus:ring-indigo-600 transition-all"
                        v-model="form.password"
                        required
                        placeholder="••••••••"
                        autocomplete="new-password"
                    />
                    <InputError class="mt-2 ml-1" :message="form.errors.password" />
                </div>

                <div>
                    <InputLabel for="password_confirmation" value="Confirm" class="text-[10px] font-black text-gray-400 tracking-widest ml-1 mb-2 uppercase" />
                    <TextInput
                        id="password_confirmation"
                        type="password"
                        class="block w-full px-5 py-3.5 bg-gray-50 border-none rounded-2xl text-sm font-bold focus:ring-2 focus:ring-indigo-600 transition-all"
                        v-model="form.password_confirmation"
                        required
                        placeholder="••••••••"
                        autocomplete="new-password"
                    />
                    <InputError class="mt-2 ml-1" :message="form.errors.password_confirmation" />
                </div>
            </div>

            <div class="pt-4">
                <button
                    class="w-full py-4 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl shadow-gray-200 hover:bg-indigo-600 hover:-translate-y-1 active:scale-[0.98] transition-all uppercase tracking-widest flex items-center justify-center gap-2"
                    :class="{ 'opacity-50 cursor-not-allowed': form.processing }"
                    :disabled="form.processing"
                >
                    <span v-if="form.processing" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                    Start Mixing Now
                </button>
            </div>

            <div class="relative py-4">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-gray-100"></div>
                </div>
                <div class="relative flex justify-center text-[10px] uppercase font-black tracking-widest">
                    <span class="bg-white px-4 text-gray-400">Or join with</span>
                </div>
            </div>

            <div class="pb-2">
                <a
                    href="/auth/google"
                    class="w-full py-4 bg-white border-2 border-gray-50 text-gray-700 rounded-2xl font-black text-sm shadow-sm hover:bg-gray-50 hover:border-gray-100 transition-all flex items-center justify-center gap-3 active:scale-[0.98]"
                >
                    <svg class="w-5 h-5" viewBox="0 0 24 24">
                        <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                        <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                        <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
                        <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                    </svg>
                    <span>Google Account</span>
                </a>

                <div class="mt-3">
                    <a
                        href="/auth/kakao"
                        class="w-full py-4 bg-[#FEE500] text-[#191919] rounded-2xl font-black text-sm shadow-sm hover:bg-[#FADA0A] transition-all flex items-center justify-center gap-3 active:scale-[0.98]"
                    >
                        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 3c-4.97 0-9 3.185-9 7.115 0 2.553 1.706 4.8 4.27 6.054-.188.702-.682 2.545-.78 2.926-.123.477.175.47.37.34.15-.1.2.37 2.4-1.485.505.14.1.23.1.23 1.04.15 2.12.23 3.24.23 4.97 0 9-3.185 9-7.115S16.97 3 12 3z"/>
                        </svg>
                        <span>Kakao Account</span>
                    </a>
                </div>
            </div>

            <div class="text-center pt-4">
                <p class="text-[11px] font-bold text-gray-400 uppercase tracking-tighter">
                    Already part of the trend? 
                    <Link :href="route('login')" class="text-indigo-600 hover:text-indigo-800 ml-1 underline underline-offset-4">
                        Login here
                    </Link>
                </p>
            </div>
        </form>
    </GuestLayout>
</template>