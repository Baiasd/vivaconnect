<script lang="ts" setup>
import {onMounted, reactive, ref} from 'vue'
import {ElMessage, FormInstance, FormRules, UploadProps} from 'element-plus'
import {ArrowLeft, Plus} from "@element-plus/icons-vue";
import {useRouter} from 'vue-router'
import {userAuthStore} from "@/store/auth";
import {storeToRefs} from "pinia";
import axios from "@/utils/axios";

const router = useRouter()

interface User {
  username: string
  password: string
  avatarUrl: string
  checkPassword: string
  roleType: string
  phone: string
  email: string
}

const authStore = userAuthStore()
const {serverIp} = storeToRefs(authStore)

const serverUrl = serverIp.value

const ruleFormRef = ref<FormInstance>()
const user = reactive<User>({
  avatarUrl: '',
  username: '',
  password: '',
  checkPassword: '',
  roleType: '业主',
  phone: '',
  email: '',
})

const imageUrl = ref('')

onMounted(async () => {

})

const handleAvatarSuccess: UploadProps['onSuccess'] = (
    response,
    uploadFile
) => {
  imageUrl.value = serverUrl + response.data;
  console.log(imageUrl.value)
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

const rules = reactive<FormRules<User>>({
  username: [
    {required: true, message: '请输入用户名', trigger: 'blur'},
    {min: 5, max: 8, message: '用户名长度应该在5~8之间', trigger: 'blur'},
  ],
  password: [
    {required: true, message: '请输入密码', trigger: 'blur'},
    {min: 6, max: 16, message: '长度需6-16位', trigger: 'blur'},
    {
      pattern: /^(?=.*[A-Za-z])(?=.*\d)/,
      message: '需包含字母和数字', trigger: 'blur'
    },
    {
      validator: (rule: any, value: any, callback: any) => {
        if (user.checkPassword !== '') {
          if (!ruleFormRef.value) return
          ruleFormRef.value.validateField('checkPassword')
          callback()
        }
      }, trigger: 'blur'
    },
  ],
  checkPassword: [ // 确认密码字段规则
    {required: true, message: '请再次输入密码', trigger: 'blur'},
    {
      validator: (rule: any, value: any, callback: any) => {
        if (value !== user.password) {
          callback(new Error("两次密码不一致!"))
        } else {
          callback()
        }
      }, trigger: 'blur'
    },
  ],
  roleType: [
    {
      required: true,
      message: '请选择角色类型',
      trigger: 'change',
    },
  ],
  phone: [
    {required: true, message: '请填写电话号码', trigger: 'blur'},
    {
      pattern: /^1[3-9]\d{9}$/,
      message: '手机号格式不正确（11位数字，以1开头）',
      trigger: 'blur'
    }
  ],
  email: [
    {required: true, message: '请填写邮箱', trigger: 'blur'},
    {
      pattern: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
      message: '邮箱格式不正确（示例：user@example.com）',
      trigger: 'blur'
    }
  ]
})

const submitForm = async (formEl: FormInstance | undefined) => {
  if (!formEl) return
  await formEl.validate((valid, fields) => {
    if (valid) {
      console.log('submit!')
      axios.post(`/api/user/save`, user).then((res) => {
        console.log(res)
      })
    } else {
      console.log('error submit!', fields)
    }
  })
}

const resetForm = (formEl: FormInstance | undefined) => {
  if (!formEl) return
  formEl.resetFields()
}
Array.from({length: 10000}).map((_, idx) => ({
  value: `${idx + 1}`,
  label: `${idx + 1}`,
}));

const goBack = () => {
  router.back();
}
</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是管理员添加页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>用户管理></el-link>
        <el-link href="/#/user/admin" type="info">管理员管理></el-link>
        <el-link disabled>添加管理员</el-link>
      </div>
    </el-col>
  </el-row>

  <el-form
      ref="ruleFormRef"
      style="max-width: 600px"
      :model="user"
      :rules="rules"
      label-width="auto"
  >
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

    <el-form-item label="用户名" prop="username">
      <el-input v-model="user.username"/>
    </el-form-item>

    <el-form-item label="密码" prop="password">
      <el-input type="password" show-password v-model="user.password"/>
    </el-form-item>
    <el-form-item label="确认密码" prop="checkPassword">
      <el-input type="password" show-password v-model="user.checkPassword"/>
    </el-form-item>
    <el-form-item label="角色类型" prop="roleType">
      <el-select v-model="user.roleType" placeholder="角色类型">
        <el-option label="管理员" value="管理员"/>
        <el-option label="维修工" value="维修工"/>
        <el-option label="业主" value="业主"/>
      </el-select>
    </el-form-item>
    <el-form-item label="手机号" prop="phone">
      <el-input v-model="user.phone"/>
    </el-form-item>
    <el-form-item label="邮箱" prop="email">
      <el-input v-model="user.email"/>
    </el-form-item>
    <el-form-item>
      <el-button type="primary" @click="submitForm(ruleFormRef)">
        提交
      </el-button>
      <el-button @click="resetForm(ruleFormRef)">重置</el-button>
    </el-form-item>
  </el-form>
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