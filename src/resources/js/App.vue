<template>
  <div class="min-h-screen bg-gray-50 text-gray-900">
    <header class="bg-indigo-600 p-4 text-white shadow-md">
      <h1 class="text-2xl font-bold">TrendVibe</h1>
    </header>

    <main class="container mx-auto py-8">
      <RemixList />
    </main>
  </div>
</template>

<script setup>
import RemixList from './components/RemixList.vue';
</script>