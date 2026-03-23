import {defineStore} from 'pinia'
import axios from "@/utils/axios.js";
import router from "@/router/router.js";

export const userAuthStore = defineStore('auth', {
    state: () => ({
        user: {
            roleType: null,
        },
        permissions: [], // 存储纯权限字符串数组
        serverIp: "http://192.168.72.128:8888/",
        isUserLoaded: false,
    }),
    actions: {
        async fetchCurrentUser() {
            try {
                const res = await axios.get('/api/user/currentUser');
                if (res.data && res.data.user) {
                    this.user = res.data.user;
                    this.permissions = res.data.authorities?.map(a => a.authority) || [];
                } else {
                    this.user = null;
                }
            } catch (error) {
                console.error("用户数据获取失败:", error);
                this.user = null;
            } finally {
                this.isUserLoaded = true; // 标记加载完成
            }
        },
        logout() {
            this.user = null
            this.permissions = []
            router.replace('/user/login')
        }
    },
    getters: {
        // 添加角色校验方法
        hasRole: (state) => (roles) => {
            return Array.isArray(roles)
                ? roles.includes(state.user?.roleType)
                : roles === state.user?.roleType
        }
    }
})