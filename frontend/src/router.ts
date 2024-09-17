import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'learn',
            component: () => import('@/views/home/HomeView.vue'),
        },
        {
            path: '/problem-set/:problemSetName',
            name: 'problem-set-detail',
            component: () => import('@/views/problem-set/ProblemSetView.vue'),
            props: true,
        },
        {
            // Catch-all not found route
            path: '/:pathMatch(.*)*',
            name: 'not-found',
            component: () => import('./views/errors/NotFoundView.vue'),
        },
    ],
});

export default router;
