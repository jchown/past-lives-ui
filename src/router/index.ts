// Composables
import { createRouter, createWebHashHistory } from 'vue-router'

const routes = [
  {
    path: process.env.NODE_ENV === 'production'
    ? '/history/past-lives/'
    : '/',
    component: () => import('@/layouts/default/Default.vue'),
    children: [
      {
        path: '/',
        name: 'Home',
        // route level code-splitting
        // this generates a separate chunk (about.[hash].js) for this route
        // which is lazy-loaded when the route is visited.
        component: () => import(/* webpackChunkName: "home" */ '@/views/Home.vue'),
      },
      {
        path: '/timeline/:name/:dob',
        name: 'Timeline',
        component: () => import('@/views/Timeline.vue'),
      },
      {
        path: '/test',
        name: 'Test',
        component: () => import('@/views/Test.vue'),
      },
      {
        path: '/:pathMatch(.*)*', 
        name: 'NotFound',
        component: () => import('@/views/NotFound.vue'),
      }
    ],
  },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

export default router
