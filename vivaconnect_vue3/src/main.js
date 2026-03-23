import {createApp} from 'vue'
import {createPinia} from 'pinia'
import App from './App.vue'
import router from './router/router.js'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import {userAuthStore} from "@/store/auth.js";

const pinia = createPinia()

const app = createApp(App);
app.use(pinia)
app.use(router)
app.use(ElementPlus, {
    location: zhCn,
})

app.directive('permission', {
    mounted(el, binding) {
        const authStore = userAuthStore()
        const requiredPerm = binding.value
        const hasPerm = authStore.permissions.includes(requiredPerm)

        if (!hasPerm) {
            el.parentNode?.removeChild(el) // 或 el.style.display = 'none'
        }
    }
})

app.directive('role', {
    mounted(el, binding) {
        const authStore = userAuthStore()
        const requiredRoles = Array.isArray(binding.value) ? binding.value : [binding.value]
        const currentRole = authStore.user?.roleType

        if (!currentRole || !requiredRoles.includes(currentRole)) {
            el.parentNode?.removeChild(el)
        }
    },
    updated(el, binding) { // 响应角色变化[7,8](@ref)
        const authStore = userAuthStore()
        const requiredRoles = Array.isArray(binding.value) ? binding.value : [binding.value]
        const currentRole = authStore.user?.roleType

        if (currentRole && requiredRoles.includes(currentRole)) {
            el.parentNode?.appendChild(el)
        } else {
            el.parentNode?.removeChild(el)
        }
    }
})

app.mount('#app')

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}

app.config.globalProperties.$auth = {
    hasPerm: (perm) => userAuthStore().permissions.includes(perm)
}
