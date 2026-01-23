<script setup>
import { useEditor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Underline from '@tiptap/extension-underline'
import Link from '@tiptap/extension-link'
import axios from 'axios';
import { watch } from 'vue'

const props = defineProps({
    modelValue: String,
});

const emit = defineEmits(['update:modelValue']);

const editor = useEditor({
    content: props.modelValue,
    extensions: [
        StarterKit,
        Underline,
        Image,
        Link.configure({ openOnClick: false }),
    ],
    editorProps: {
        attributes: {
            class: 'prose max-w-none focus:outline-none min-h-[400px] p-6 shadow-inner bg-white overflow-y-auto',
        },
    },
    onUpdate: () => {
        emit('update:modelValue', editor.value.getHTML());
    },
});

watch(() => props.modelValue, (value) => {
    if (editor.value && editor.value.getHTML() !== value) {
        editor.value.commands.setContent(value, false);
    }
});

// 이미지 업로드 핸들러 (파일 선택창 띄우기)
const triggerImageUpload = () => {
    // 업로드 방식 확인
    const choice = window.confirm(
        "사진 업로드 방식을 선택하세요.\n\n[확인]: 내 컴퓨터에서 파일 선택\n[취소]: 이미지 주소(URL) 직접 입력"
    );

    if (choice) {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = 'image/*';
        input.onchange = async () => {
            const file = input.files[0];
            if (file) {
                // FormData 객체 생성
                const formData = new FormData();
                formData.append('image', file);

                try {
                    // 서버로 업로드 요청
                    const response = await axios.post(route('image.upload'), formData, {
                        headers: { 'Content-Type': 'multipart/form-data' }
                    });

                    // 서버가 돌려준 URL을 에디터에 삽입
                    const url = response.data.url;
                    editor.value.chain().focus().setImage({ src: url }).run();
                } catch (error) {
                    alert('이미지 업로드에 실패했습니다.');
                    console.error(error);
                }
            }
        };
        input.click();
    } else {
        const url = window.prompt('이미지 URL 입력:');
        if (url) editor.value.chain().focus().setImage({ src: url }).run();
    }
};
</script>

<template>
    <div class="border border-gray-200 rounded-[1.5rem] overflow-hidden bg-gray-50 shadow-sm">
        <div v-if="editor" class="flex flex-wrap items-center gap-1 p-3 border-b border-gray-200 bg-gray-50/50">
            <div class="flex items-center gap-1 border-r border-gray-300 pr-2 mr-1">
                <button @click.prevent="editor.chain().focus().toggleBold().run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('bold') }" class="toolbar-btn font-bold">B</button>
                <button @click.prevent="editor.chain().focus().toggleItalic().run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('italic') }" class="toolbar-btn italic">I</button>
                <button @click.prevent="editor.chain().focus().toggleUnderline().run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('underline') }" class="toolbar-btn underline">U</button>
                <button @click.prevent="editor.chain().focus().toggleStrike().run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('strike') }" class="toolbar-btn line-through">S</button>
            </div>

            <div class="flex items-center gap-1 border-r border-gray-300 pr-2 mr-1">
                <button @click.prevent="editor.chain().focus().toggleHeading({ level: 2 }).run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('heading', { level: 2 }) }" class="toolbar-btn font-black text-sm">H2</button>
                <button @click.prevent="editor.chain().focus().toggleHeading({ level: 3 }).run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('heading', { level: 3 }) }" class="toolbar-btn font-black text-xs">H3</button>
            </div>

            <div class="flex items-center gap-1 border-r border-gray-300 pr-2 mr-1">
                <button @click.prevent="editor.chain().focus().toggleBulletList().run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('bulletList') }" class="toolbar-btn">• List</button>
                <button @click.prevent="editor.chain().focus().toggleBlockquote().run()" :class="{ 'bg-indigo-100 text-indigo-600': editor.isActive('blockquote') }" class="toolbar-btn">“ Quote</button>
            </div>

            <div class="flex items-center gap-1">
                <button @click.prevent="triggerImageUpload" class="toolbar-btn">Image</button>
                <button @click.prevent="editor.chain().focus().setHorizontalRule().run()" class="toolbar-btn">Line </button>
                <button @click.prevent="editor.chain().focus().undo().run()" class="toolbar-btn text-gray-400">Undo</button>
            </div>
        </div>
        
        <editor-content :editor="editor" />
    </div>
</template>

<style scoped>
.toolbar-btn {
    @apply px-3 py-1.5 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-200 hover:text-gray-900 transition-all active:scale-95 flex items-center justify-center;
}

/* TipTap 기본 스타일 커스텀 */
:deep(.tiptap) {
    outline: none !important;
}
:deep(.tiptap img) {
    @apply rounded-2xl shadow-lg my-4 max-w-full h-auto border-4 border-white;
}
:deep(.tiptap blockquote) {
    @apply border-l-4 border-indigo-500 pl-4 py-2 bg-indigo-50/50 rounded-r-lg italic text-gray-600;
}
:deep(.tiptap ul) {
    @apply list-disc pl-6 my-4;
}
</style>