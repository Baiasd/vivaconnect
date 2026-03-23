<script lang="ts" setup>
import {useRouter} from 'vue-router'
import {onMounted, reactive, ref} from 'vue'
import {CollapseModelValue, dayjs} from 'element-plus'
import axios from "@/utils/axios";
import {userAuthStore} from "@/store/auth";
import {storeToRefs} from "pinia";

const router = useRouter()

interface User {
  username: string
  avatarUrl: string
  roleType: string
  phone: string
  email: string
  detail: number
  createdAt: Date | string
  maintainer: Maintainer
}

interface Maintainer {
  realName: string
  idCard: string
  gender: string
  birthday: Date | string
  age: number
  jobType: string
  salary: number
  certificateOfSkill: string
}

const authStore = userAuthStore()
const {serverIp} = storeToRefs(authStore)

const serverUrl = serverIp.value


const user = reactive({} as User)
const maintainer = reactive({} as Maintainer)

const loadUser = async () => {
  const userData = (await axios.get('/api/user/CurrentUserWithNoPermission')).data
  console.log(userData.avatarUrl)
  console.log(serverUrl)
  userData.avatarUrl = serverUrl + userData.avatarUrl
  userData.maintainer.certificateOfSkill = serverUrl + userData.maintainer.certificateOfSkill
  Object.assign(user, userData)
  Object.assign(maintainer, userData.maintainer)
}

onMounted(async () => {
  await loadUser()
  console.log(user)
  console.log(serverUrl)
})

const onEdit = () => {
  router.push({
    name: 'EditMaintainerMessage',
  })
}

const activeNames = ref(['1'])
const handleChange = (val: CollapseModelValue) => {
  console.log(val)
}

</script>

<template>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是维修工信息页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>个人信息></el-link>
        <el-link disabled>个人信息</el-link>
      </div>
    </el-col>
  </el-row>


  <div class="demo-collapse" style="min-height: 60vh">
    <el-collapse v-model="activeNames" @change="handleChange">
      <el-collapse-item title="基础信息" name="1">
        <el-descriptions class="margin-top"
                         border>
          <el-descriptions-item
              :rowspan="2"
              :width="140"
              label="头像"
              align="center"
          >
            <el-image
                :src="user.avatarUrl"
                :zoom-rate="1.2"
                :max-scale="7"
                :min-scale="0.2"
                :preview-src-list="[user.avatarUrl]"
                show-progress
                :initial-index="4"
                fit="cover"
            >
              <template #error>
                <div class="image-slot">
                  <el-image src="src/assets/noPicture-grey.png"></el-image>
                </div>
              </template>
            </el-image>
          </el-descriptions-item>
          <el-descriptions-item align="center" label="用户名">
            {{ user.username }}
          </el-descriptions-item>
          <el-descriptions-item align="center" label="手机号">{{ user.phone }}</el-descriptions-item>
          <el-descriptions-item align="center" label="邮箱">{{ user.email }}</el-descriptions-item>
          <el-descriptions-item align="center" label="创建时间">{{
              dayjs(user.createdAt).format('YYYY-MM-DD HH:mm:ss')
            }}
          </el-descriptions-item>
        </el-descriptions>

      </el-collapse-item>
      <el-collapse-item title="详细信息" name="2">
        <el-descriptions
            class="margin-top"
            :column="3"
            border
        >
          <el-descriptions-item align="center" label="姓名">{{ maintainer.realName }}</el-descriptions-item>
          <el-descriptions-item align="center" label="身份证号">{{ maintainer.idCard }}</el-descriptions-item>
          <el-descriptions-item align="center" label="性别">{{ maintainer.gender }}</el-descriptions-item>
          <el-descriptions-item align="center" label="生日">{{
              dayjs(maintainer.birthday).format("YYYY-MM-DD")
            }}
          </el-descriptions-item>
          <el-descriptions-item align="center" label="年龄">{{ maintainer.age }}</el-descriptions-item>
          <el-descriptions-item align="center" label="工种">{{ maintainer.jobType }}</el-descriptions-item>
          <el-descriptions-item align="center" label="薪资">{{ maintainer.salary }}</el-descriptions-item>
          <el-descriptions-item align="center" label="证书">
            <el-image
                style="width: 200px; height: 200px"
                :src="maintainer.certificateOfSkill"
                :zoom-rate="1.2"
                :max-scale="7"
                :min-scale="0.2"
                :preview-src-list="[maintainer.certificateOfSkill]"
                show-progress
                :initial-index="4"
                fit="cover"
            >
              <template #error>
                <div class="image-slot">
                  <el-image src="src/assets/noPicture-grey.png"></el-image>
                </div>
              </template>
            </el-image>
          </el-descriptions-item>
        </el-descriptions>
      </el-collapse-item>
    </el-collapse>
    <el-button type="primary" @click="onEdit">修改个人信息</el-button>
  </div>

</template>

<style scoped>
</style>