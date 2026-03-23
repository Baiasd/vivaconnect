<script lang="ts" setup>
import {computed, onBeforeUnmount, ref} from 'vue'
import axios from 'axios'
import {useRouter} from 'vue-router'
import {Lock, User} from "@element-plus/icons-vue";
import {userAuthStore} from "@/store/auth";
import type {TabsPaneContext} from 'element-plus'

// 初始化路由实例
const router = useRouter()
const username = ref('')
const password = ref('')
const code = ref('')
const message = ref('')


const activeName = ref('first')

const handleClick = (tab: TabsPaneContext, event: Event) => {
  console.log(tab, event)
  username.value = ''
  password.value = ''
  code.value = ''
}


const loginPassword = async () => {
  const form = new FormData()
  form.append('username', username.value)
  form.append('password', password.value)
  const loginData = (await axios.post('/api/login', form))
  console.log(loginData)
  if (loginData.code === 200) {
    const userData = (await axios.get('/api/user/CurrentUserWithNoPermission')).data
    console.log(userData)
    if (userData.roleType == "管理员") {
      const authStore = userAuthStore()
      await authStore.fetchCurrentUser()
      await router.push('/user/index')
    } else if (userData.roleType == "业主") {
      await router.push('/owner/index')
    } else if (userData.roleType == "维修工") {
      await router.push('/maintainer/index')
    }
  } else {
    message.value = loginData.message
  }
}

const loginCode = async () => {
  const form = new FormData()
  form.append('username', username.value)
  form.append('code', code.value)
  const loginData = (await axios.post('/api/loginCode', form))
  console.log(loginData)
  if (loginData.code === 200) {
    const userData = (await axios.get('/api/user/CurrentUserWithNoPermission')).data
    console.log(userData)
    if (userData.roleType == "管理员") {
      const authStore = userAuthStore()
      await authStore.fetchCurrentUser()
      await router.push('/user/index')
    } else if (userData.roleType == "业主") {
      await router.push('/owner/index')
    } else if (userData.roleType == "维修工") {
      await router.push('/maintainer/index')
    }
  } else {
    message.value = loginData.message
  }
}

const login = () => {
  console.log(111)
  if (code.value === "" && password.value !== "") {
    console.log(password.value)
    loginPassword()
  } else if (code.value !== "" && password.value === "") {
    console.log(code.value)
    loginCode()
  }
}

const getCode = () => {
  console.log(username.value)
  axios.post('/api/user/sendCode', {username: username.value}).then((res) => {
    console.log(res)
    if (res.code === 200) {
      startCountdown(60) // 开始60秒倒计时
    }
  })
}

// 倒计时状态
const countdown = ref(0)
const isCounting = ref(false)
let timer = null

// 按钮文字计算属性
const buttonText = computed(() => {
  return isCounting.value ? `${countdown.value}秒后重新获取` : '获取验证码'
})
// 开始倒计时
const startCountdown = (seconds) => {
  isCounting.value = true
  countdown.value = seconds

  timer = setInterval(() => {
    countdown.value--

    if (countdown.value <= 0) {
      clearInterval(timer)
      isCounting.value = false
    }
  }, 1000)
}

// 组件卸载前清除定时器
onBeforeUnmount(() => {
  if (timer) clearInterval(timer)
})


const register = () => {
  router.push('/user/register')
}

</script>

<template>

  <div style="display: flex; justify-content: center; align-items: center; min-height: 80vh;">
    <el-card body-style="width: 50%; min-width: 400px;">
      <template #header>
        <div style="text-align: center;">
          <span>社区报修管理系统</span>
        </div>
      </template>


      <el-tabs v-model="activeName" class="demo-tabs" @tab-click="handleClick">
        <el-tab-pane label="密码登录" name="first">
          <el-form label-width="auto">
            <el-form-item label="用户名">
              <el-input
                  v-model="username"
                  style="width: 300px; height: 40px"
                  placeholder="请输入用户名"
                  :prefix-icon="User"
              />
            </el-form-item>
            <el-form-item label="密码">
              <el-input
                  v-model="password"
                  style="width: 300px; height: 40px"
                  type="password"
                  placeholder="请输入密码"
                  :prefix-icon="Lock"
              />
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="验证码登录" name="second">
          <el-form label-width="auto">
            <el-form-item label="用户名" :inline="true">
              <el-input
                  v-model="username"
                  style="width: 300px; height: 40px"
                  placeholder="请输入用户名"
                  :prefix-icon="User"
              />
            </el-form-item>
            <el-form-item label="验证码">
              <el-input
                  v-model="code"
                  style="width: 180px; height: 40px; margin-right: 20px"
                  placeholder="请输入验证码"
                  :prefix-icon="Lock"
              />
              <el-button type="primary" :disabled="isCounting" @click="getCode">{{ buttonText }}</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>

      <template #footer>
        <el-button type="primary" @click="login">登录</el-button>
        <el-button @click="register">注册</el-button>
        <label v-if="message != null">{{ message.value }}</label>
      </template>
    </el-card>
  </div>
</template>


<style scoped>
</style>