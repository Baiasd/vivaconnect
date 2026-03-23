<script setup>

import router from "@/router/router.js";
import {Tools} from "@element-plus/icons-vue";
import {userAuthStore} from '@/store/auth' // 导入用户存储
import {storeToRefs} from 'pinia'
import axios from "@/utils/axios.js";
import {onMounted} from "vue"; // 保持响应式解构

const authStore = userAuthStore()
const {user,serverIp} = storeToRefs(authStore)

const serverUrl = serverIp.value

const logout = () => {
  axios.post('/api/user/logout').then(response => {
    if (response.code === 200) {
      const authStore = userAuthStore()
      authStore.logout()
    }
  })
}

onMounted(() => {
  console.log(user)
  console.log(serverUrl)
})


const onDetail = () => {
  router.push({
    name: 'AdminDetail',
    params: {
      uid: user.value.uid
    }
  })
}

</script>

<template>
  <el-row align="middle" justify="space-between">
    <el-col :span="6">
      <div class="brand" style="text-align: center">
        <el-icon size="40">
          <Tools/>
        </el-icon>
        <div class="titles">
          <el-link href="/#/">
            <h1>社区服务管理系统</h1>
          </el-link>
        </div>
      </div>
    </el-col>

    <el-col :span="2" v-if="user != null && user.uid != null">
      <el-dropdown>
        <span class="el-dropdown-link" style="display: inline-flex; align-items: center;">
          <span style="font-size: 40px; line-height: 1">{{ user.username }}</span>
          <el-avatar :size="60" :src="serverUrl + user.avatarUrl" style="flex-shrink: 0">
            <img src="https://cube.elemecdn.com/e/fd/0fc7d20532fdaf769a25683617711png.png"/>
          </el-avatar>
        </span>
        <template #dropdown>
          <el-dropdown-menu v-if="user.roleType === '管理员'">
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="router.push('/user')"
                  icon="House"
              >用户首页
              </el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="onDetail"
                  icon="Avatar"
              >个人信息
              </el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="logout"
                  icon="SwitchButton"
              >退出登录
              </el-button>
            </el-dropdown-item>
          </el-dropdown-menu>

          <el-dropdown-menu v-else-if="user.roleType === '业主'">
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="router.push('/owner')"
                  icon="House"
              >用户首页
              </el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="router.push('/owner/message')"
                  icon="Avatar"
              >个人信息
              </el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="logout"
                  icon="SwitchButton"
              >退出登录
              </el-button>
            </el-dropdown-item>
          </el-dropdown-menu>

          <el-dropdown-menu v-else-if="user.roleType === '维修工'">
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="router.push('/maintainer')"
                  icon="House"
              >用户首页
              </el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="router.push('/maintainer/message')"
                  icon="House"
              >个人信息
              </el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button
                  type="text"
                  @click="logout"
                  icon="SwitchButton"
              >退出登录
              </el-button>
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </el-col>
    <el-col :span="2" v-else>
      <el-button @click="router.push('/user/login')">登录</el-button>
      <el-button @click="router.push('/user/register')">注册</el-button>
    </el-col>

  </el-row>
</template>

<style scoped>
.main-header {
  background: #fff;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  height: 80px;
}

.brand {
  display: flex;
  align-items: center;
  gap: 15px;
}

.logo {
  width: 50px;
}

.titles h1 {
  font-size: 24px;
  color: #2c3e50;
  margin: 0;
}

.subtitle {
  font-size: 14px;
  color: #7f8c8d;
  margin: 0;
}

.nav-right {
  display: flex;
  justify-content: flex-end;
  gap: 20px;
}
</style>