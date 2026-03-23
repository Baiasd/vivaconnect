<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onMounted, reactive, ref, watch} from 'vue'
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
  permissions: Permission[]
}

interface Permission {
  permissionName: string
  permissionDesc: string
}

interface User {
  username: string
  avatarUrl: string
  roleType: string
  phone: string
  email: string
  createdAt: Date | string
  role: Role
}

interface Detail {
  realName: string
  idCard: string
  gender: string
  birthday: Date | string
  age: number
  jobType: string
  salary: number
  CertificateOfSkill: string
}

const authStore = userAuthStore()
const {serverIp} = storeToRefs(authStore)

const serverUrl = serverIp.value

const uid = route.params.uid
const user = reactive({} as User)
const maintainer = reactive({} as Detail)
const role = reactive({} as Role);
const roleList = ref<Role[]>([])

const loadUser = async () => {
  const userData = (await axios.get('/api/user/findById', {
    params: {uid}
  })).data
  userData.avatarUrl = serverUrl + userData.avatarUrl
  userData.maintainer.CertificateOfSkill = serverUrl + userData.maintainer.CertificateOfSkill
  Object.assign(user, userData)
  Object.assign(maintainer, userData.maintainer)
  Object.assign(role, userData.role)
}

const loadRoleList = (async (roleType) => {
  // 获取角色列表
  roleList.value = (await axios.get(`/api/role/findRoleListByType`, {
    params: {roleType: user.roleType}
  })).data;
})

onMounted(async () => {
  await loadUser()
})

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

const onSubmit_Role = () => {
  console.log('submit!')
  axios.put(`/api/user/updateRoleById`, {
    uid: uid,
    role: role
  }).then(data => {
    console.log(data)
  })
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
        <h1>这是维修工详情页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>用户管理></el-link>
        <el-link href="/#/user/maintainer" type="info">维修工管理></el-link>
        <el-link disabled>维修工详情</el-link>
      </div>
    </el-col>
  </el-row>


  <div class="demo-collapse" style="min-height: 60vh">
    <el-collapse v-model="activeNames" @change="handleChange">
      <el-collapse-item title="维修工基础信息" name="1">
        <el-descriptions border>
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
          <el-descriptions-item align="center" label="用户名">{{ user.username }}</el-descriptions-item>
          <el-descriptions-item align="center" label="角色类别">{{ user.roleType }}</el-descriptions-item>
          <el-descriptions-item align="center" label="手机号">{{ user.phone }}</el-descriptions-item>
          <el-descriptions-item align="center" label="邮箱">{{ user.email }}</el-descriptions-item>
          <el-descriptions-item align="center" label="创建时间">{{
              dayjs(user.createdAt).format('YYYY-MM-DD HH:mm:ss')
            }}
          </el-descriptions-item>
        </el-descriptions>

      </el-collapse-item>
      <el-collapse-item title="维修工详细信息" name="2">
        <el-descriptions
            class="margin-top"
            :column="4"
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
          <el-descriptions-item align="center" label="薪资" :span="2">{{ maintainer.salary }}</el-descriptions-item>
          <el-descriptions-item align="center" label="证明">
            <el-image
                style="width: 200px; height: 200px"
                :src="maintainer.CertificateOfSkill"
                :zoom-rate="1.2"
                :max-scale="7"
                :min-scale="0.2"
                :preview-src-list="[maintainer.CertificateOfSkill]"
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
      <el-collapse-item title="角色详情" name="3">
<!--        <el-descriptions border v-if="user.role">-->
<!--          <el-descriptions-item align="center" label="角色名称">{{ user.role.roleName }}</el-descriptions-item>-->
<!--          <el-descriptions-item align="center" label="角色详情">{{ user.role.roleDesc }}</el-descriptions-item>-->
<!--          <el-descriptions-item align="center" label="角色类型">{{ user.role.roleType }}</el-descriptions-item>-->
<!--        </el-descriptions>-->

        <el-form>
          <el-descriptions border v-if="user.role">
            <el-descriptions-item align="center" label="角色名称">
              <el-select
                  v-model="role.roleName"
                  placeholder="Select"
                  size="large"
                  style="width: 100%"
                  @visible-change="loadRoleList"
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

        <el-collapse-item title="权限列表" name="4" style="margin-left: 10px" v-if="user.role">
          <el-row v-for="(item, index) in user.role.permissions" :key="index">
            <el-col :span="6">{{ item.permissionName }}</el-col>
            <el-col :span="6">{{ item.permissionDesc }}</el-col>
          </el-row>
        </el-collapse-item>
      </el-collapse-item>
    </el-collapse>
  </div>

</template>

<style scoped>
</style>