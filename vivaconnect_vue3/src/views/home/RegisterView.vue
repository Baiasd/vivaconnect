<script setup lang="ts">

import {reactive, ref} from "vue";
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";
import {useRouter} from 'vue-router'
import {FormInstance, FormRules} from "element-plus";

interface User {
  username: string
  password: string
  avatarUrl: string
  checkPassword: string
  roleType: string
  phone: string
  email: string
}

const user = reactive({
  avatarUrl: '',
  username: '',
  password: '',
  checkPassword: '',
  roleType: '业主',
  phone: '',
  email: '',
} as User)


const router = useRouter()


const ruleFormRef = ref<FormInstance>()

const rules = reactive<FormRules<User>>({
  username: [
    {required: true, message: '请输入用户名', trigger: 'blur'},
    {min: 3, max: 8, message: '用户名长度应该在3~8之间', trigger: 'blur'},
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
  ],
})

const submitForm = async (formEl: FormInstance | undefined) => {
  if (!formEl) return
  await formEl.validate((valid, fields) => {
    if (valid) {
      console.log('submit!')
      console.log(formEl)
      axios.post('/api/user/save', user)
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
  <div style="margin-top: 20px;min-height: 600px">
    <el-button :icon="ArrowLeft" @click="goBack" style="margin-left: 60px;margin-bottom: 100px">返回</el-button>

    <div style="display: flex; align-items: center;justify-content: center;">
      <el-form
          ref="ruleFormRef"
          style="max-width: 600px; width: 100%"
          :model="user"
          :rules="rules"
          label-width="auto"
      >

        <el-form-item label="用户名" prop="username">
          <el-input v-model="user.username"/>
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input type="password" show-password v-model="user.password"/>
        </el-form-item>
        <el-form-item label="确认密码" prop="checkPassword">
          <el-input type="password" show-password v-model="user.checkPassword"/>
        </el-form-item>
        <el-form-item label="身份" prop="roleType">
          <el-select v-model="user.roleType" placeholder="身份">
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
    </div>
  </div>

</template>

<style scoped>

</style>