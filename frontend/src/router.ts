import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'learn',
            component: () => import('@/views/learn/LearnView.vue'),
        },
    ],
});

export default router;
