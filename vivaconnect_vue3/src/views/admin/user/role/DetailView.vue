<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onMounted, reactive, ref} from 'vue'
import {CollapseModelValue} from 'element-plus'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";

const route = useRoute()
const router = useRouter()

interface Role {
  roleName: string
  roleDesc: string
  roleType: string
  permissions: Permission[]
}

interface Permission {
  permissionName: string
  permissionDesc: string
}

const rid = route.query.rid
const role = reactive({} as Role)
ref<Permission[]>([]);
onMounted(async () => {
  await axios.get(`/api/role/findById`, {
    params: {rid}
  }).then((res) => {
    Object.assign(role, res.data)
    console.log(role)
  })
})
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
      <el-collapse-item title="角色详情" name="1">
        <el-descriptions border>
          <el-descriptions-item align="center" label="角色名称">{{ role.roleName }}</el-descriptions-item>
          <el-descriptions-item align="center" label="角色详情">{{ role.roleDesc }}</el-descriptions-item>
          <el-descriptions-item align="center" label="角色类型">{{ role.roleType }}</el-descriptions-item>
        </el-descriptions>
      </el-collapse-item>
      <el-collapse-item title="权限列表" name="2">
        <el-row v-for="(item, index) in role.permissions" :key="index">
          <el-col :span="6">{{ item.permissionName }}</el-col>
          <el-col :span="6">{{ item.permissionDesc }}</el-col>
        </el-row>
      </el-collapse-item>
    </el-collapse>
  </div>

</template>

<style scoped>
</style>