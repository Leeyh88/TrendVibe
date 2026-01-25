<script setup>
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import TextInput from '@/Components/TextInput.vue';
import { useForm, usePage } from '@inertiajs/vue3';
import { ref } from 'vue';

defineProps({
    mustVerifyEmail: {
        type: Boolean,
    },
    status: {
        type: String,
    },
});

const user = usePage().props.auth.user;

const photoPreview = ref(null);
const photoInput = ref(null);

const form = useForm({
    _method: 'PATCH',
    name: user.name,
    email: user.email,
    public_email: user.public_email || '',
    profile_photo: null,
    soundcloud_url: user.soundcloud_url || '',
    youtube_url: user.youtube_url || '',
    daw_info: user.daw_info || '',
    bio: user.bio || '',
    donation_info: user.donation_info || '',
});

const updatePhotoPreview = () => {
    const photo = photoInput.value.files[0];
    if (!photo) return;
    form.profile_photo = photo;

    const reader = new FileReader();
    reader.onload = (e) => {
        photoPreview.value = e.target.result;
    };
    reader.readAsDataURL(photo);
};

const submit = () => {
    form.post(route('profile.update'), {
        preserveScroll: true,
        onSuccess: () => {
            form.profile_photo = null;
            // 성공 시 미리보기는 유지하거나, 서버에서 새로 받아온 데이터를 쓸 수 있도록 초기화 로직을 상황에 맞게 조절 가능합니다.
        },
    });
};
</script>

<template>
    <section>
        <header>
            <h2 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                <span class="w-1.5 h-6 bg-indigo-600 rounded-full"></span>
                아티스트 프로필 정보
            </h2>
            <p class="mt-1 text-sm text-gray-500 font-medium">이미지와 활동 정보를 설정하여 자신을 홍보하세요.</p>
        </header>

        <form @submit.prevent="submit" class="mt-6 space-y-8">
            
            <div class="flex items-center gap-6">
                <div 
                    @click="photoInput.click()"
                    class="relative w-24 h-24 rounded-[2rem] overflow-hidden border-4 border-indigo-50 shadow-md bg-gray-100 cursor-pointer group transition-all hover:ring-4 hover:ring-indigo-200"
                >
                    <input type="file" ref="photoInput" class="hidden" @change="updatePhotoPreview" accept="image/*" />
                    
                    <img v-if="photoPreview" :src="photoPreview" class="w-full h-full object-cover" />
                    
                    <img v-else-if="user.profile_photo_path" :src="'/storage/' + user.profile_photo_path" class="w-full h-full object-cover" />
                    
                    <div v-else class="w-full h-full flex items-center justify-center text-gray-400">
                        <svg class="w-10 h-10" fill="currentColor" viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                    </div>

                    <div class="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                        <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                        </svg>
                    </div>
                </div>

                <div>
                    <h3 class="font-bold text-gray-900 text-sm">프로필 사진</h3>
                    <p class="text-[10px] text-gray-400 mt-1 uppercase font-bold tracking-wider">이미지를 클릭하여 변경하세요</p>
                    <InputError :message="form.errors.profile_photo" class="mt-1" />
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <InputLabel for="name" value="활동 닉네임" />
                    <TextInput id="name" type="text" class="mt-1 block w-full" v-model="form.name" required />
                    <InputError class="mt-2" :message="form.errors.name" />
                </div>
                <div>
                    <InputLabel for="public_email" value="연락 이메일 (Public)" />
                    <TextInput id="public_email" type="email" class="mt-1 block w-full" v-model="form.public_email" />
                    <InputError class="mt-2" :message="form.errors.public_email" />
                </div>
            </div>

            <div class="space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <InputLabel for="soundcloud_url" value="SoundCloud URL" />
                        <TextInput id="soundcloud_url" type="url" class="mt-1 block w-full" v-model="form.soundcloud_url" placeholder="https://soundcloud.com/your-id" />
                        <InputError class="mt-2" :message="form.errors.soundcloud_url" />
                    </div>
                    <div>
                        <InputLabel for="youtube_url" value="YouTube URL" />
                        <TextInput id="youtube_url" type="url" class="mt-1 block w-full" v-model="form.youtube_url" placeholder="https://youtube.com/@your-id" />
                        <InputError class="mt-2" :message="form.errors.youtube_url" />
                    </div>
                </div>

                <div>
                    <InputLabel for="daw_info" value="주력 DAW (사용 장비)" />
                    <TextInput id="daw_info" type="text" class="mt-1 block w-full" v-model="form.daw_info" placeholder="FL Studio, Ableton Live, Logic Pro 등" />
                    <p class="mt-1 text-[10px] text-gray-400 font-bold uppercase tracking-widest">다른 유저들이 당신의 작업 환경을 알 수 있습니다.</p>
                    <InputError class="mt-2" :message="form.errors.daw_info" />
                </div>

                <div>
                    <InputLabel for="bio" value="아티스트 한줄 소개" />
                    <textarea 
                        id="bio" 
                        rows="2"
                        class="mt-1 block w-full border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 rounded-xl shadow-sm transition-all"
                        v-model="form.bio"
                        placeholder="당신의 음악 스타일을 짧게 소개해 주세요."
                    ></textarea>
                    <InputError class="mt-2" :message="form.errors.bio" />
                </div>
            </div>

            <hr class="border-gray-100" />

            <div class="bg-indigo-50/50 p-6 rounded-[2rem] border border-indigo-100/50">
                <InputLabel for="donation_info" value="후원 정보 (Donation)" class="text-indigo-600 font-black" />
                <textarea 
                    id="donation_info" 
                    rows="3"
                    class="mt-2 block w-full border-gray-200 focus:border-indigo-500 focus:ring-indigo-500 rounded-xl shadow-sm transition-all"
                    v-model="form.donation_info"
                    placeholder="예: 카카오페이 송금 링크 또는 은행 계좌번호 (국민 000-00...)"
                ></textarea>
                <InputError class="mt-2" :message="form.errors.donation_info" />
            </div>

            <div class="flex items-center gap-4 pt-4">
                <button
                    class="px-8 py-3 bg-indigo-600 text-white rounded-2xl font-black text-sm hover:bg-indigo-700 transition-all shadow-lg shadow-indigo-100 disabled:opacity-50"
                    :disabled="form.processing"
                >
                    저장하기
                </button>

                <Transition
                    enter-active-class="transition ease-in-out"
                    enter-from-class="opacity-0"
                    leave-active-class="transition ease-in-out"
                    leave-to-class="opacity-0"
                >
                    <p v-if="form.recentlySuccessful" class="text-sm font-bold text-indigo-600">
                        성공적으로 반영되었습니다.
                    </p>
                </Transition>
            </div>
        </form>
    </section>
</template>