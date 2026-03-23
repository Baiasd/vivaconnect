<script setup lang="ts">

import {onMounted, reactive, ref, watch} from "vue";
import axios from "@/utils/axios";
import {ArrowLeft, Plus} from "@element-plus/icons-vue";
import type {UploadProps, UploadUserFile} from 'element-plus'
import router from "@/router/router";
import {useRoute} from "vue-router";

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

const route = useRoute()
const rid = Number(route.params.rid)
const repairOrder = reactive({} as RepairOrder)
const originalOrder = reactive({} as RepairOrder)
const area = reactive({} as Area);
const building = reactive({} as Building);
const room = reactive({} as Room);
const areaList = ref<Area[]>([])
const buildingList = ref<Building[]>([])
const roomList = ref<Room[]>([])
const faultTypeList = ref<FaultType[]>([])
const imageList = ref<UploadUserFile[]>([])

const loadRepairOrder = async () => {
  const orderData = (await axios.get('/api/repair/repairOrder/findById', {
    params: {
      rid: rid
    }
  })).data
  Object.assign(repairOrder, orderData)
  console.log("订单信息", repairOrder)
  Object.assign(originalOrder, orderData)
}

const loadAreaList = (async () => {
  // 获取区域列表
  areaList.value = (await axios.get(`/api/address/area/findAreaListByStatus`)).data;
  console.log("区域列表：", areaList.value);
  if (areaList.value.length == 0) {
    repairOrder.areaName = ''
    area.areaName = ''
  }
})

const loadBuildingList = (async () => {
  // 获取区域列表
  buildingList.value = (await axios.get(`/api/address/building/findAreaListByStatusAndAid`, {
    params: {
      aid: area.aid,
    }
  })).data;
  console.log("楼宇列表：", buildingList.value);
  if (buildingList.value.length == 0) {
    repairOrder.buildingName = ''
    building.buildingName = ''
  }
})

const loadRoomList = (async () => {
  // 获取区域列表
  if (building.buildingName != '') {
    roomList.value = (await axios.get(`/api/address/room/findRoomListByBidAndStatus`, {
      params: {
        bid: building.bid
      }
    })).data;
    console.log("房间列表：", roomList.value);

  }
  if (roomList.value.length == 0) {
    repairOrder.roomNumber = ''
    room.roomNumber = '';
  }
})

const loadFaultTypeList = (async () => {
  // 获取区域列表
  faultTypeList.value = (await axios.get(`/api/repair/faultType/findFaultTypeList`)).data;
  console.log("报修类型列表：", faultTypeList.value);
})

onMounted(async () => {
  await loadRepairOrder();
  await loadAreaList();
  updateArea(repairOrder.areaName);
  await loadBuildingList();
  updateBuilding(repairOrder.buildingName)
  repairOrder.images = []
})

watch(() => repairOrder.faultType, (newVal) => {
  const faultType = faultTypeList.value.find(item => item.faultType === newVal);
  if (faultType) {
    repairOrder.urgency = faultType.urgency
  }
});

const updateArea = (areaName: string) => {
  const selectArea = areaList.value.find(area => area.areaName === areaName);
  if (selectArea) {
    Object.assign(area, selectArea);
  }
}

const updateBuilding = (buildName: string) => {
  const selectBuilding = buildingList.value.find(building => building.buildingName === buildName);
  if (selectBuilding) {
    Object.assign(building, selectBuilding);
  }
}


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


const onSubmit = async () => {
  console.log('submit!')
  console.log(repairOrder.images)
  if (repairOrder.status == '草稿') {
    repairOrder.status = '待分配'
  }
  axios.put(`/api/repair/repairOrder/updateById`, repairOrder).then(data => {
    console.log(data)
  })
}

const onReset = () => {
  Object.assign(repairOrder, originalOrder)
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
          v-model="repairOrder.areaName"
          placeholder="Select"
          size="large"
          style="width: 100%"
          @visible-change="loadAreaList"
          @change="updateArea"
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
          v-model="repairOrder.buildingName"
          placeholder="Select"
          size="large"
          style="width: 100%"
          @visible-change="loadBuildingList"
          @change="updateBuilding"
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
          v-model="repairOrder.roomNumber"
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
      <el-button type="primary" @click="onSubmit">提交</el-button>
      <el-button @click="onReset">重置</el-button>
    </el-form-item>
  </el-form>
</template>

<style scoped>

</style>