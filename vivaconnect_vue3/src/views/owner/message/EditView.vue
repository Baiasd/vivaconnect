<script lang="ts" setup>
import {useRouter} from 'vue-router'
import {onMounted, reactive, ref, watch} from 'vue'
import {CollapseModelValue, dayjs, ElMessage, UploadProps, UploadRawFile} from 'element-plus'
import axios from "@/utils/axios";
import {ArrowLeft, Plus} from "@element-plus/icons-vue";
import {userAuthStore} from "@/store/auth";
import {storeToRefs} from "pinia";

const router = useRouter()


interface User {
  uid: number
  username: string
  password: string
  avatarUrl: string
  roleType: string
  phone: string
  email: string
  detail: number
  createdAt: Date | string
}

interface Detail {
  oid: number
  realName: string
  idCard: string
  gender: string
  birthday: Date | string
  age: number
  area: number | string
  building: number | string
  room: number | string
  houseOwnershipCertificate: string
}

interface Area {
  aid: number
  areaName: string
  status: string
  createTime: Date | string
  area: number
}

interface Building {
  bid: number
  buildingName: string
}

interface Room {
  rid: number
  roomNumber: string
}

const authStore = userAuthStore()
const {serverIp} = storeToRefs(authStore)

const serverUrl = serverIp.value

const user = reactive({} as User);
const owner = reactive({} as Detail);
const area = reactive({} as Area);
const building = reactive({} as Building);
const room = reactive({} as Room);
const areaList = ref<Area[]>([])
const buildingList = ref<Building[]>([])
const roomList = ref<Room[]>([])
const avatarUrl = ref('')
const houseOwnershipCertificateUrl = ref('')


const isEditPassWord = ref<boolean>(false)
const originalUser = reactive({} as User)
const originalOwner = reactive({} as Detail);
const checkPassword = ref<number>()
const uploadType = ref<string>('')

const loadUser = (async () => {
  const userData = (await axios.get('/api/user/CurrentUserWithNoPermission')).data
  Object.assign(user, userData)
  Object.assign(originalUser, userData)
  console.log("用户信息：", user)
  avatarUrl.value = serverUrl + userData.avatarUrl
  Object.assign(owner, userData.owner)
  console.log("业主信息：", owner)
  houseOwnershipCertificateUrl.value = serverUrl + userData.owner.houseOwnershipCertificate
})

const loadAreaList = (async () => {
  // 获取区域列表
  areaList.value = (await axios.get(`/api/address/area/findAreaListByStatus`)).data;
  console.log("区域列表：", areaList.value);
})

const loadBuildingList = (async () => {

  // 获取区域列表
  buildingList.value = (await axios.get(`/api/address/building/findAreaListByStatusAndAid`, {
    params: {
      aid: owner.area,
    }
  })).data;
  console.log("楼宇列表：", buildingList.value);
})

const loadRoomList = (async () => {
  // 获取区域列表
  roomList.value = (await axios.get(`/api/address/room/findRoomListByBidAndStatus`, {
    params: {
      bid: owner.building
    }
  })).data;
  console.log("房间列表：", roomList.value);
})

const loadArea = (async (aid: number | string) => {
  const areaData = (await axios.get(`/api/address/area/getById`, {
    params: {aid: aid}
  })).data
  Object.assign(area, areaData)
})

const loadBuilding = (async (bid: number | string) => {
  const buildingData = (await axios.get(`/api/address/building/getById`, {
    params: {bid: bid}
  })).data
  Object.assign(building, buildingData)
})

const loadRoom = (async (rid: number | string) => {
  const roomData = (await axios.get(`/api/address/room/getById`, {
    params: {rid: rid}
  })).data
  Object.assign(room, roomData)
})

onMounted(async () => {
  await loadAreaList()
  await loadUser()
  await loadArea(owner.area)
  await loadBuilding(owner.building)
  await loadRoom(owner.room)
});

watch(() => area.aid, (newVal) => {
  owner.area = newVal
  loadBuildingList()
})

watch(() => building.bid, (newVal) => {
  owner.building = newVal
  loadRoomList()
})

// 监听生日变化，计算年龄
watch(() => owner.birthday, (newDate) => {
  if (!newDate) {
    return;
  }
  owner.age = calculateAge(newDate);
});

// 年龄计算函数（兼容闰年与时区）
const calculateAge = (birthday) => {
  const today = dayjs();
  const birthDate = dayjs(birthday);
  let age = today.year() - birthDate.year();
  const isBirthdayPassed = today.isAfter(birthDate.set('year', today.year()));
  return isBirthdayPassed ? age : age - 1;
};

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
  // 确保后端返回的 data 字段包含图片 URL
  console.log(uploadFile)
  console.log(uploadType.value)
  if (response.code === 200 && response.data) {
    console.log(response.data)
    if (uploadType.value === 'avatar') {
      avatarUrl.value = serverUrl + response.data;
      console.log(avatarUrl.value)
      user.avatarUrl = response.data
    } else if (uploadType.value === 'houseOwnershipCertificate') {
      houseOwnershipCertificateUrl.value = serverUrl + response.data;
      owner.houseOwnershipCertificate = response.data;
    }

  } else {
    ElMessage.error(response.message || '上传失败');
  }
}

const beforeAvatarUpload = (rawFile: UploadRawFile, type: string) => {
  // 允许所有图片类型（MIME 类型以 "image/" 开头）

  console.log(rawFile)
  console.log(type)
  uploadType.value = type
  if (!rawFile.type.startsWith('image/')) { // [7,8](@ref)
    ElMessage.error('仅支持图片格式文件！');
    return false;
  } else if (rawFile.size / 1024 / 1024 > 2) {
    ElMessage.error('Avatar picture size can not exceed 2MB!')
    return false
  }
  return true
}

const EditPassword = () => {
  if (isEditPassWord) {
    user.password = originalUser.password;
  }
  isEditPassWord.value = !isEditPassWord.value
}

const onSubmit_Basic = () => {
  console.log('submit!')
  console.log(checkPassword.value)
  axios.put(`/api/user/updateById`, user).then(data => {
    console.log(data)
  })
}

const onReset_Basic = () => {
  Object.assign(user, originalUser)
}

const onSubmit_Detail = () => {
  console.log('submit!')
  console.log(owner)
  axios.put(`/api/user/owner/updateById`, owner).then(data => {
    console.log(data)
  })
}

const onReset_Detail = () => {
  Object.assign(owner, originalOwner)
}

</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是业主修改页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>用户管理></el-link>
        <el-link href="/#/user/owner" type="info">业主管理></el-link>
        <el-link disabled>业主修改</el-link>
      </div>
    </el-col>
  </el-row>


  <div class="demo-collapse" style="min-height: 60vh">
    <el-collapse v-model="activeNames" @change="handleChange">
      <el-collapse-item title="业主基础信息修改" name="1">
        <el-form :model="user" label-width="auto" style="max-width: 600px">
          <el-form-item label="头像">
            <el-upload
                class="avatar-uploader"
                action="/api/file/uploadImage"
                :show-file-list="false"
                :on-success="handleAvatarSuccess"
                :before-upload="(file) => beforeAvatarUpload(file,'avatar')"
            >
              <img v-if="avatarUrl" :src="avatarUrl" style="width: 150px; height: 150px"/>
              <el-icon v-else class="avatar-uploader-icon">
                <Plus/>
              </el-icon>
            </el-upload>
          </el-form-item>

          <el-form-item label="用户名">
            <el-input v-model="user.username"/>
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="user.phone"/>
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="user.email"/>
          </el-form-item>
          <el-button v-if="!isEditPassWord" @click="EditPassword">修改密码</el-button>
          <el-button v-if="isEditPassWord" @click="EditPassword">取消</el-button>
          <el-form-item v-if="isEditPassWord" label="密码">
            <el-input v-model="user.password" type="password"/>
          </el-form-item>
          <el-form-item v-if="isEditPassWord" label="确认密码">
            <el-input v-model="checkPassword" type="password" show-password/>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit_Basic">提交</el-button>
            <el-button @click="onReset_Basic">重置</el-button>
          </el-form-item>
        </el-form>
      </el-collapse-item>
      <el-collapse-item title="业主详细信息修改" name="2">
        <el-form :model="owner" label-width="auto" style="max-width: 600px">
          <el-form-item label="姓名">
            <el-input v-model="owner.realName"/>
          </el-form-item>
          <el-form-item label="身份证号">
            <el-input v-model="owner.idCard"/>
          </el-form-item>
          <el-form-item label="性别">
            <el-select
                v-model="owner.gender"
                placeholder="Select"
                size="large"
                style="width: 100%"
            >
              <el-option value="男"/>
              <el-option value="女"/>
            </el-select>
          </el-form-item>
          <el-form-item label="生日">
            <el-date-picker
                v-model="owner.birthday"
                type="date"
            />
          </el-form-item>
          <el-form-item label="年龄">
            <el-input v-model="owner.age"/>
          </el-form-item>
          <el-form-item label="区域">
            <el-select
                v-model="area.aid"
                placeholder="Select"
                size="large"
                style="width: 100%"
            >
              <el-option
                  v-for="item in areaList"
                  :key="item.aid"
                  :label="item.areaName"
                  :value="item.aid"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="楼号">
            <el-select
                v-model="building.bid"
                placeholder="Select"
                size="large"
                style="width: 100%"
            >
              <el-option
                  v-for="item in buildingList"
                  :key="item.bid"
                  :label="item.buildingName"
                  :value="item.bid"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="房号">
            <el-select
                v-model="room.rid"
                placeholder="Select"
                size="large"
                style="width: 100%"
            >
              <el-option
                  v-for="item in roomList"
                  :key="item.rid"
                  :label="item.roomNumber"
                  :value="item.rid"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="住房证明">
            <el-upload
                class="avatar-uploader"
                action="/api/file/uploadImage"
                :show-file-list="false"
                :on-success="handleAvatarSuccess"
                :before-upload="(file) => beforeAvatarUpload(file,'houseOwnershipCertificate')"
            >
              <img v-if="houseOwnershipCertificateUrl" :src="houseOwnershipCertificateUrl"
                   style="width: 150px; height: 150px"/>
              <el-icon v-else class="avatar-uploader-icon">
                <Plus/>
              </el-icon>
            </el-upload>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit_Detail">提交</el-button>
            <el-button @click="onReset_Detail">重置</el-button>
          </el-form-item>
        </el-form>
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