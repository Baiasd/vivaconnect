<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onMounted, reactive, ref, watch} from 'vue'
import type {UploadProps} from 'element-plus'
import {CollapseModelValue, ElMessage} from 'element-plus'
import axios from "@/utils/axios";
import {ArrowLeft, Plus} from "@element-plus/icons-vue";
import {userAuthStore} from "@/store/auth";
import {storeToRefs} from "pinia";

const route = useRoute()
const router = useRouter()

interface Role {
  rid: number
  roleName: string
  roleDesc: string
  roleType: string
  permissions: Permission[]
}

interface Permission {
  permissionName: string
  permissionDesc: string
}

interface Admin {
  username: string
  avatarUrl: string
  roleType: string
  phone: string
  email: string
  createdAt: Date | string
  role: Role
}

const authStore = userAuthStore()
const {serverIp} = storeToRefs(authStore)

const serverUrl = serverIp.value
const imageUrl = ref('')


const uid = Number(route.params.uid)
const user = reactive({} as Admin);
const role = reactive({} as Role);
const roleList = ref<Role[]>([])

const loadUser = (async () => {
  // 获取用户信息
  const data = (await axios.get(`/api/user/findById`, {params: {uid}})).data;

  imageUrl.value = serverUrl + data.avatarUrl
  Object.assign(user, data)
  Object.assign(role, data.role)
  console.log(user)

})

const loadRoleList = (async (roleType) => {
  // 获取角色列表
  roleList.value = (await axios.get(`/api/role/findRoleListByType`, {
    params: {roleType: roleType}
  })).data;
})

onMounted(async () => {
  await loadUser()
  await loadRoleList(user.roleType)
});

// 监听角色名称变化
watch(() => role.roleName, (newVal) => {
  const selectedRole = roleList.value.find(item => item.roleName === newVal);
  if (selectedRole) {
    Object.assign(role, selectedRole)
  }
});

const activeNames = ref(['1'])
const handleChange = (val: CollapseModelValue) => {
  console.log(val)
}

const goBack = () => {
  router.back();
}


const handleAvatarSuccess: UploadProps['onSuccess'] = (
    response,
    uploadFile
) => {
  imageUrl.value = serverUrl + response.data;
  user.avatarUrl = response.data
}

const beforeAvatarUpload: UploadProps['beforeUpload'] = (rawFile) => {
  if (!rawFile.type.startsWith('image/')) { // [7,8](@ref)
    ElMessage.error('仅支持图片格式文件！');
    return false;
  } else if (rawFile.size / 1024 / 1024 > 2) {
    ElMessage.error('Avatar picture size can not exceed 2MB!')
    return false
  }
  return true
}

const onSubmit_Basic = () => {
  console.log('submit!')
  axios.put(`/api/user/updateById`, user).then(data => {
    console.log(data)
  })
}

const onSubmit_Role = () => {
  console.log('submit!')
  axios.put(`/api/user/updateRoleById`, {
    uid: uid,
    role: role
  }).then(data => {
    console.log(data)
  })
}
</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是管理员修改页面</h1>
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
        <el-form :model="user" label-width="auto" style="max-width: 600px">
          <el-form-item label="头像">
            <el-upload
                class="avatar-uploader"
                action="/api/file/uploadImage"
                :show-file-list="false"
                :on-success="handleAvatarSuccess"
                :before-upload="beforeAvatarUpload"
            >
              <img v-if="imageUrl" :src="imageUrl" style="width: 150px; height: 150px"/>
              <el-icon v-else class="avatar-uploader-icon">
                <Plus/>
              </el-icon>
            </el-upload>
          </el-form-item>

          <el-form-item label="用户名">
            <el-input v-model="user.username"/>
          </el-form-item>
          <el-form-item label="角色类别">
            <el-input disabled v-model="user.roleType"/>
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="user.phone"/>
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="user.email"/>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit_Basic">提交</el-button>
            <el-button>重置</el-button>
          </el-form-item>
        </el-form>
      </el-collapse-item>

      <el-collapse-item title="角色详情" name="3">

        <el-form>
          <el-descriptions border>
            <el-descriptions-item align="center" label="角色名称">
              <el-select
                  v-model="role.roleName"
                  placeholder="Select"
                  size="large"
                  style="width: 100%"
              >
                <el-option
                    v-for="item in roleList"
                    :key="item.roleName"
                    :label="item.roleDesc"
                    :value="item.roleName"
                />
              </el-select>
            </el-descriptions-item>
            <el-descriptions-item align="center" label="角色详情">{{ role.roleDesc }}</el-descriptions-item>
            <el-descriptions-item align="center" label="角色类型">{{ role.roleType }}</el-descriptions-item>

          </el-descriptions>
          <el-form-item>
            <el-button type="primary" @click="onSubmit_Role">提交</el-button>
            <el-button>重置</el-button>
          </el-form-item>
        </el-form>


        <el-collapse-item title="权限列表" name="4" style="margin-left: 10px">
          <el-row v-for="(item, index) in role.permissions" :key="index">
            <el-col :span="6">{{ item.permissionName }}</el-col>
            <el-col :span="6">{{ item.permissionDesc }}</el-col>
          </el-row>
        </el-collapse-item>
      </el-collapse-item>

    </el-collapse>
  </div>
</template>

<style scoped>
.avatar-uploader .el-upload {
  border: 1px dashed var(--el-border-color);
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: var(--el-transition-duration-fast);
}

.avatar-uploader .el-upload:hover {
  border-color: var(--el-color-primary);
}

.el-icon.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
}
</style>