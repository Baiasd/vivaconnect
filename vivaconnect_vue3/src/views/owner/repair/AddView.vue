<script setup lang="ts">

import {onMounted, reactive, ref, watch} from "vue";
import axios from "@/utils/axios";
import {ArrowLeft, Plus} from "@element-plus/icons-vue";
import type {UploadProps, UploadUserFile} from 'element-plus'
import router from "@/router/router";


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
  owner: Owner
}

interface Owner {
  oid: number
  realName: string
  idCard: string
  gender: string
  birthday: Date | string
  age: number
  area: number | string
  building: number | string
  room: number | string
  house_ownership_certificate: string
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
interface RepairOrder {
  rid: number
  ownerId: number
  maintainerId: number
  faultType: string
  description: string
  areaName: string
  buildingName: string
  roomNumber: string
  status: string
  urgency: number
  images: { url: string }[]
  materials: []
  cost: number
}

interface FaultType {
  fid: number
  faultType: string
  urgency: number
}

const repairOrder = reactive({
  faultType: '未知',
  status: '草稿',
  urgency: 3,
} as RepairOrder)

const user = reactive({} as User);
const originalUser = reactive({} as User)
const area = reactive({} as Area);
const building = reactive({} as Building);
const room = reactive({} as Room);
const areaList = ref<Area[]>([])
const buildingList = ref<Building[]>([])
const roomList = ref<Room[]>([])
const faultTypeList = ref<FaultType[]>([])
const imageList = ref<UploadUserFile[]>([])


const loadUser = (async () => {
  const userData = (await axios.get('/api/user/CurrentUserWithNoPermission')).data
  Object.assign(user, userData)
  Object.assign(originalUser, userData)
  console.log("用户信息：", user)
  console.log("业主信息：", userData.owner)
})

const loadArea = (async (aid: number | string) => {
  const areaData = (await axios.get(`/api/address/area/getById`, {
    params: {aid: aid}
  })).data
  Object.assign(area, areaData)
  console.log("区域信息：", areaData)
})

const loadBuilding = (async (bid: number | string) => {
  const buildingData = (await axios.get(`/api/address/building/getById`, {
    params: {bid: bid}
  })).data
  Object.assign(building, buildingData)
  console.log("楼宇信息：", buildingData)
})

const loadRoom = (async (rid: number | string) => {
  const roomData = (await axios.get(`/api/address/room/getById`, {
    params: {rid: rid}
  })).data
  Object.assign(room, roomData)
  console.log("住房信息：", roomData)
})

const loadAreaList = (async () => {
  // 获取区域列表
  areaList.value = (await axios.get(`/api/address/area/findAreaListByStatus`)).data;
  console.log("区域列表：", areaList.value);
  if (areaList.value.length == 0) {
    area.areaName = ''
    user.owner.area = ''
  }
})

const loadBuildingList = (async () => {
  // 获取区域列表
  console.log(user.owner.area)
  buildingList.value = (await axios.get(`/api/address/building/findAreaListByStatusAndAid`, {
    params: {
      aid: user.owner.area,
    }
  })).data;
  console.log("楼宇列表：", buildingList.value);
  if (buildingList.value.length == 0) {
    building.buildingName = ''
    user.owner.building = ''
  }
})

const loadRoomList = (async () => {
  // 获取区域列表
  if (user.owner.building != '') {
    roomList.value = (await axios.get(`/api/address/room/findRoomListByBidAndStatus`, {
      params: {
        bid: user.owner.building
      }
    })).data;
    console.log("房间列表：", roomList.value);

  }
  if (roomList.value.length == 0) {
    room.roomNumber = '';
  }
})

const loadFaultTypeList = (async () => {
  // 获取区域列表
  faultTypeList.value = (await axios.get(`/api/repair/faultType/findFaultTypeList`)).data;
  console.log("报修类型列表：", faultTypeList.value);
})

onMounted(async () => {
  await loadUser()
  await loadArea(user.owner.area)
  await loadBuilding(user.owner.building)
  await loadRoom(user.owner.room)
  repairOrder.images = []
})

const updateOwnerArea = (areaName: string) => {
  const selectArea = areaList.value.find(area => area.areaName === areaName);
  console.log(selectArea);
  if (selectArea) {
    user.owner.area = selectArea?.aid;
  }
}

const updateOwnerBuilding = (buildName: string) => {
  const selectBuilding = buildingList.value.find(building => building.buildingName === buildName);
  if (selectBuilding) {
    user.owner.building = selectBuilding?.bid;
  }
}

watch(() => repairOrder.faultType, (newVal) => {
  const faultType = faultTypeList.value.find(item => item.faultType === newVal);
  if (faultType) {
    repairOrder.urgency = faultType.urgency
  }
});

const dialogImageUrl = ref('')
const dialogVisible = ref(false)

const handleRemove: UploadProps['onRemove'] = (uploadFile, uploadFiles) => {
  console.log(uploadFile, uploadFiles)
  console.log(imageList)
}

const handlePictureCardPreview: UploadProps['onPreview'] = (uploadFile) => {
  dialogImageUrl.value = uploadFile.url!
  dialogVisible.value = true
}

const handleUploadSuccess = (response, file) => {
  repairOrder.images.push({url: response.data})
  console.log(repairOrder.images)
};

const updateRepairOrder = async () => {
  repairOrder.ownerId = user.uid
  repairOrder.areaName = area.areaName
  repairOrder.buildingName = building.buildingName
  repairOrder.roomNumber = room.roomNumber
  console.log(repairOrder)
}

const onSave = async () => {
  console.log('submit!')
  await updateRepairOrder()

  if (repairOrder.rid == null) {
    repairOrder.ownerId = user.uid
    axios.post(`/api/repair/repairOrder/save`, repairOrder).then(res => {
      repairOrder.rid = res.data
      console.log(res)
    })
  } else {
    axios.put(`/api/repair/repairOrder/updateById`, repairOrder).then(data => {
      console.log(data)
    })
  }
}

const onSubmit = async () => {
  console.log('submit!')
  repairOrder.status = '待分配'
  await updateRepairOrder()
  if (repairOrder.rid == null) {
    repairOrder.ownerId = user.uid
    await axios.post(`/api/repair/repairOrder/save`, repairOrder).then(res => {
      repairOrder.rid = res.data
      console.log(res.data)
    })
  } else {
    await axios.put(`/api/repair/repairOrder/updateById`, repairOrder).then(res => {
      console.log(res.data)
    })
  }
  await router.push("/owner/repair/order")
}

const onReset = () => {
  Object.assign(user, originalUser)
}

const goBack = () => {
  router.back();
}
</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>
  <el-form :model="repairOrder" label-width="auto" style="max-width: 600px">
    <el-form-item label="报修类型">
      <el-select
          v-model="repairOrder.faultType"
          placeholder="Select"
          size="large"
          style="width: 100%"
          @visible-change="loadFaultTypeList"
      >
        <el-option
            v-for="item in faultTypeList"
            :key="item.fid"
            :label="item.faultType"
            :value="item.faultType"
        />
      </el-select>
    </el-form-item>

    <el-form-item label="区域">
      <el-select
          v-model="area.areaName"
          placeholder="Select"
          size="large"
          style="width: 100%"
          @visible-change="loadAreaList"
          @change="updateOwnerArea"
      >
        <el-option
            v-for="item in areaList"
            :key="item.aid"
            :label="item.areaName"
            :value="item.areaName"
        />
      </el-select>
    </el-form-item>
    <el-form-item label="楼号">
      <el-select
          v-model="building.buildingName"
          placeholder="Select"
          size="large"
          style="width: 100%"
          @visible-change="loadBuildingList"
          @change="updateOwnerBuilding"
      >
        <el-option
            v-for="item in buildingList"
            :key="item.bid"
            :label="item.buildingName"
            :value="item.buildingName"
        />
      </el-select>
    </el-form-item>
    <el-form-item label="房号">
      <el-select
          v-model="room.roomNumber"
          placeholder="Select"
          size="large"
          style="width: 100%"
          @visible-change="loadRoomList"
      >
        <el-option
            v-for="item in roomList"
            :key="item.rid"
            :label="item.roomNumber"
            :value="item.roomNumber"
        />
      </el-select>
    </el-form-item>

    <el-form-item label="描述">
      <el-input v-model="repairOrder.description" type="textarea"/>
    </el-form-item>
    <el-form-item label="问题图片">
      <el-upload
          v-model:file-list="imageList"
          action="/api/file/uploadImage"
          list-type="picture-card"
          :on-preview="handlePictureCardPreview"
          :on-remove="handleRemove"
          :on-success="handleUploadSuccess"
      >
        <el-icon>
          <Plus/>
        </el-icon>
      </el-upload>

      <el-dialog v-model="dialogVisible">
        <img w-full :src="dialogImageUrl" alt="Preview Image"
             style="max-width: 100%; max-height: 100%; object-fit: contain; margin: 0 auto;"/>
      </el-dialog>
    </el-form-item>
    <el-form-item>
      <el-button type="primary" @click="onSave">保存</el-button>
      <el-button type="primary" @click="onSubmit">提交</el-button>
      <el-button @click="onReset">重置</el-button>
    </el-form-item>
  </el-form>
</template>

<style scoped>

</style>