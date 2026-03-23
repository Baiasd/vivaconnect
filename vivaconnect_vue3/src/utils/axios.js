import axios from 'axios'
import {ElMessage} from 'element-plus'
import router from '@/router/router.js'

// 响应拦截器
// utils/axios.js
import {userAuthStore} from '@/store/auth.js'

axios.interceptors.response.use(
    res => {
        const {data = {}, status} = res
        if (status === 200) {
            if (data.code !== 200) {
                ElMessage.error(data.message)
                if (data.code === 401) {
                    console.log(data.code)
                    router.push({path: '/user/login'})
                    return
                }
                if (data.code === 403) {
                    router.push({path: '/noPermission'})
                }
                return Promise.resolve(data)
            }
            return data
        } else {
            const {status, statusText} = res
            ElMessage.error(status + statusText)
            return Promise.reject(res)
        }
    },
    error => {
        if (error.response?.status === 401) {
            const authStore = userAuthStore()
            // 清除用户信息
            authStore.user = null
            authStore.permissions = []
            // 跳转登录页
            router.push('/user/login')
        }
        return Promise.reject(error)
    }
)
axios.defaults.withCredentials = true
export default axios
