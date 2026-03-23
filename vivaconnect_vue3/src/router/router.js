import {createRouter, createWebHashHistory} from 'vue-router'
import Layout from "@/layout/layout.vue";
import {userAuthStore} from "@/store/auth.js"
import IndexLayout from "@/layout/IndexLayout.vue";

const routes = [
    {
        path: '/',
        redirect: '/index',
        component: IndexLayout,
        children: [
            {
                path: '/index',
                name: 'Home',
                component: () => import('@/views/home/index.vue'),
                meta:{
                    title: '首页',
                }
            },
            {
                path: '/noPermission',
                name: 'NoPermission',
                component: () => import('@/views/home/NoPermission.vue'),
            },
            {
                path: '/user/login',
                name: 'Login',
                component: () => import('@/views/home/Login.vue'),
                meta:{
                    title: '登录',
                }
            },
            {
                path: '/user/register',
                name: 'Register',
                component: () => import('@/views/home/RegisterView.vue'),
            },
            {
                path: '/notice',
                name: 'NoticePage',
                component: () => import('@/views/notice/NoticeView.vue'),
            },
            {
                path: '/notice/detail/:nid',
                name: 'DetailNotice',
                component: () => import('@/views/notice/DetailView.vue'),
            },
        ]
    },
    {
        path: '/user',
        redirect: '/user/index',
        component: Layout,
        children: [
            {
                path: '/user/index',
                name: 'UserIndex',
                component: () => import('@/views/admin/index.vue'),
            },
            {
                path: '/user/admin',
                name: 'Admin',
                component: () => import('@/views/admin/user/admin/AdminView.vue'),
            },
            {
                path: '/user/admin/add',
                name: 'AddAdmin',
                component: () => import('@/views/admin/user/admin/AddView.vue'),
            },
            {
                path: '/user/admin/edit/:uid',
                name: 'EditAdmin',
                component: () => import('@/views/admin/user/admin/EditView.vue'),
            },
            {
                path: '/user/admin/detail/:uid',
                name: 'AdminDetail',
                component: () => import('@/views/admin/user/admin/DetailView.vue'),
            },
            {
                path: '/user/owner',
                name: 'Owner',
                component: () => import('@/views/admin/user/owner/OwnerView.vue'),
            },
            {
                path: '/user/owner/detail/:uid',
                name: 'OwnerDetail',
                component: () => import('@/views/admin/user/owner/DetailView.vue'),
            },
            {
                path: '/user/maintainer',
                name: 'Maintainer',
                component: () => import('@/views/admin/user/maintainer/MaintainerView.vue'),
            },
            {
                path: '/user/maintainer/detail/:uid',
                name: 'MaintainerDetail',
                component: () => import('@/views/admin/user/maintainer/DetailView.vue'),
            },
            {
                path: '/user/role',
                name: 'Role',
                component: () => import('@/views/admin/user/role/RoleView.vue'),
            },
            {
                path: '/user/role/add',
                name: 'AddRole',
                component: () => import('@/views/admin/user/role/AddView.vue'),
            },
            {
                path: '/user/role/edit',
                name: 'EditRole',
                component: () => import('@/views/admin/user/role/EditView.vue'),
            },
            {
                path: '/user/role/detail',
                name: 'RoleDetail',
                component: () => import('@/views/admin/user/role/DetailView.vue'),
            },
            {
                path: '/user/permission',
                name: 'Permission',
                component: () => import('@/views/admin/user/permission/PermissionView.vue'),
            },
            {
                path: '/user/notice',
                name: 'Notice',
                component: () => import('@/views/admin/notice/NoticeView.vue'),
            },
            {
                path: '/user/notice/add',
                name: 'AddNotice',
                component: () => import('@/views/admin/notice/AddView.vue'),
            },
            {
                path: '/user/notice/edit/:nid',
                name: 'EditNotice',
                component: () => import('@/views/admin/notice/EditView.vue'),
            },
            {
                path: '/user/notice/detail/:nid',
                name: 'NoticeDetail',
                component: () => import('@/views/admin/notice/DetailView.vue'),
            },
            {
                path: '/user/address/area',
                name: 'Area',
                component: () => import('@/views/admin/address/area/AreaView.vue'),
            },
            {
                path: '/user/address/building',
                name: 'Building',
                component: () => import('@/views/admin/address/building/BuildingView.vue'),
            },
            {
                path: '/user/address/building/add',
                name: 'AddBuilding',
                component: () => import('@/views/admin/address/building/AddView.vue'),
            },
            {
                path: '/user/address/building/edit/:bid',
                name: 'EditBuilding',
                component: () => import('@/views/admin/address/building/EditView.vue'),
            },
            {
                path: '/user/address/room',
                name: 'Room',
                component: () => import('@/views/admin/address/room/RoomView.vue'),
            },
            {
                path: '/user/address/room/add',
                name: 'AddRoom',
                component: () => import('@/views/admin/address/room/AddView.vue'),
            },
            {
                path: '/user/address/room/edit/:rid/:bid',
                name: 'EditRoom',
                component: () => import('@/views/admin/address/room/EditView.vue'),
            },
            {
                path: '/user/repair/order',
                name: 'UserOrder',
                component: () => import('@/views/admin/repair/OrderView.vue'),
            },
            {
                path: '/user/repair/comment/:rid',
                name: 'OrderComment',
                component: () => import('@/views/admin/repair/CommentView.vue'),
            },
            {
                path: '/user/repair/dispatch/:rid',
                name: 'OrderDispatch',
                component: () => import('@/views/admin/repair/DispatchView.vue'),
            },
            {
                path: '/user/repair/faultType',
                name: 'FaultType',
                component: () => import('@/views/admin/repair/FaultTypeView.vue'),
            },
            {
                path: '/user/repair/jobType',
                name: 'JobType',
                component: () => import('@/views/admin/repair/JobTypeView.vue'),
            },
        ]

    },
    {
        path: '/owner',
        redirect: '/owner/index',
        component: Layout,
        children: [
            {
                path: '/owner/index',
                name: 'OwnerIndex',
                component: () => import('@/views/owner/index.vue'),
            },
            {
                path: '/owner/message',
                name: 'OwnerMessage',
                component: () => import('@/views/owner/message/MessageView.vue'),
            },
            {
                path: '/owner/message/edit',
                name: 'EditOwnerMessage',
                component: () => import('@/views/owner/message/EditView.vue'),
            },
            {
                path: '/owner/repair/order',
                name: 'OwnerOrder',
                component: () => import('@/views/owner/repair/OrderView.vue'),
            },
            {
                path: '/owner/repair/order/add',
                name: 'AddOrder',
                component: () => import('@/views/owner/repair/AddView.vue'),
            },
            {
                path: '/owner/repair/order/detail/:rid',
                name: 'OrderDetail',
                component: () => import('@/views/repair/DetailView.vue'),
            },
            {
                path: '/owner/repair/order/edit/:rid',
                name: 'EditOrder',
                component: () => import('@/views/owner/repair/EditView.vue'),
            },
            {
                path: '/owner/comment/:cid/:uid',
                name: 'CommentOrder',
                component: () => import('@/views/owner/comment/CommentView.vue'),
            },
        ]

    },
    {
        path: '/maintainer',
        redirect: '/maintainer/index',
        component: Layout,
        children: [
            {
                path: '/maintainer/index',
                name: 'MaintainerIndex',
                component: () => import('@/views/maintainer/index.vue'),
            },
            {
                path: '/maintainer/message',
                name: 'MaintainerMessage',
                component: () => import('@/views/maintainer/message/MessageView.vue'),
            },
            {
                path: '/maintainer/message/edit',
                name: 'EditMaintainerMessage',
                component: () => import('@/views/maintainer/message/EditView.vue'),
            },
            {
                path: '/maintainer/repair/order',
                name: 'MaintainerOrder',
                component: () => import('@/views/maintainer/repair/OrderView.vue'),
            },
            {
                path: '/maintainer/repair/takenOrder',
                name: 'MaintainerTakenOrder',
                component: () => import('@/views/maintainer/repair/MaintainerTakenOrderView.vue'),
            },
            {
                path: '/maintainer/repair/order/detail/:rid',
                name: 'OrderDetail',
                component: () => import('@/views/repair/DetailView.vue'),
            },
        ]

    },
]

const router = createRouter
({
    history: createWebHashHistory(),
    routes
})

router.beforeEach(async (to) => {
    // 允许访问的路径列表
    const allowedPaths = [
        '/index',
        '/user/register',
        // 匹配所有/statistic/开头的路径
        /^\/statistic(\/.*)?$/,
        // 匹配所有/user/notice/detail/开头的路径
        /^\/user\/notice\/detail(\/.*)?$/,
    ];

    // 检查当前路径是否匹配允许的路径
    if (allowedPaths.some(pattern => {
        if (typeof pattern === 'string') {
            return to.path === pattern;
        } else if (pattern instanceof RegExp) {
            return pattern.test(to.path);
        }
        return false;
    })) {
        return true; // 允许访问
    }

    const authStore = userAuthStore()

    // 如果未登录且目标不是登录页，直接跳转登录
    if (!authStore.user && to.path !== '/user/login') {
        return '/user/login'
    }

    // 已登录但权限数据未加载时获取用户信息
    if (authStore.user && !authStore.permissions.length) {
        try {
            await authStore.fetchCurrentUser()
        } catch (error) {
            // 获取失败时清除用户状态并跳转登录
            authStore.user = null
            return '/user/login'
        }
    }

    // 原有权限检查逻辑
    if (to.meta?.permissions) {
        const hasPermission = to.meta.permissions.every(p =>
            authStore.permissions.includes(p)
        )
        return hasPermission ? true : '/noPermission'
    }

    if(to.meta.title){
        document.title = to.meta.title
    }
})

export default router