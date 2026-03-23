<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onMounted, ref} from 'vue'
import {CollapseModelValue, dayjs} from 'element-plus'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";
import {userAuthStore} from "@/store/auth";
import {storeToRefs} from "pinia";

const route = useRoute()
const router = useRouter()

interface Role {
  roleName: string
  roleDesc: string
  roleType: string
}

interface Permission {
  permissionName: string
  permissionDesc: string
}

interface Admin {
  uid: number
  username: string
  avatarUrl: string
  roleType: string
  phone: string
  email: string
  createdAt: Date | string
  role: Role
}

const authStore = userAuthStore()
const {user,serverIp} = storeToRefs(authStore)     // 响应式解构用户对象[6](@ref)

const serverUrl = serverIp.value

const uid = route.params.uid
const admin = ref<Admin | null>(null)
const permissions = ref<Permission[]>([])

onMounted(async () => {
  await axios.get(`/api/user/findById`, {
    params: {uid}
  }).then((res) => {
    res.data.avatarUrl = serverUrl + res.data.avatarUrl
    admin.value = res.data
    permissions.value = res.data.role.permissions
    console.log(res.data)
  })
})

const onEdit = () => {
  router.push({
    name: 'EditAdmin',
    params: {
      uid: admin.value?.uid,
    }
  })
}

const activeNames = ref(['1'])
const handleChange = (val: CollapseModelValue) => {
  console.log(val)
}

const goBack = () => {
  router.back();
}
</script>

<template>

  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是管理员角色详情页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>用户管理></el-link>
        <el-link href="/#/user/admin" type="info">管理员管理></el-link>
        <el-link disabled>管理员修改</el-link>
      </div>
    </el-col>
  </el-row>


  <div class="demo-collapse" style="min-height: 60vh">
    <el-collapse v-model="activeNames" @change="handleChange">
      <el-collapse-item title="管理员信息" name="1">
        <el-descriptions border>
          <el-descriptions-item
              :rowspan="2"
              :width="140"
              label="头像"
              align="center"
          >
            <el-image
                style="width: 100px; height: 100px"
                :src="admin?.avatarUrl"
            />
          </el-descriptions-item>
          <el-descriptions-item align="center" label="用户名">{{ admin?.username }}</el-descriptions-item>
          <el-descriptions-item align="center" label="角色类别">{{ admin?.roleType }}</el-descriptions-item>
          <el-descriptions-item align="center" label="手机号">{{ admin?.phone }}</el-descriptions-item>
          <el-descriptions-item align="center" label="邮箱">{{ admin?.email }}</el-descriptions-item>
          <el-descriptions-item align="center" label="创建时间">{{
              dayjs(admin?.createdAt).format('YYYY-MM-DD HH:mm:ss')
            }}
          </el-descriptions-item>
        </el-descriptions>

      </el-collapse-item>

      <el-collapse-item title="角色详情" name="3">
        <el-descriptions border>
          <el-descriptions-item align="center" label="角色名称">{{ admin?.role.roleName }}</el-descriptions-item>
          <el-descriptions-item align="center" label="角色详情">{{ admin?.role.roleDesc }}</el-descriptions-item>
          <el-descriptions-item align="center" label="角色类型">{{ admin?.role.roleType }}</el-descriptions-item>
        </el-descriptions>

        <el-collapse-item title="权限列表" name="4" style="margin-left: 10px">
          <el-row v-for="(item, index) in permissions" :key="index">
            <el-col :span="6">{{ item.permissionName }}</el-col>
            <el-col :span="6">{{ item.permissionDesc }}</el-col>
          </el-row>
        </el-collapse-item>
      </el-collapse-item>
    </el-collapse>
    <el-button v-if="admin?.uid === user.uid" type="primary" @click="onEdit">修改个人信息</el-button>
  </div>

</template>

<style scoped>
</style>