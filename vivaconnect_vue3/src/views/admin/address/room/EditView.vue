<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onMounted, reactive, ref} from 'vue'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";

const router = useRouter()

interface Building {
  bid: number
  aid: number
  buildingName: string
  floorTotal: number
  floorGround: number
  floorUnderground: number
  buildingPurpose: string
  constructionTime: Date | string
  totalArea: number
  isClosed: boolean
  elevatorCount: number
  fireSystemStatus: boolean
  updateTime: Date | string
}

interface Room {
  rid: number
  bid: number
  roomNumber: string
  status: boolean
  saleTime: Date | string
  ownerId: number
  updateTime: Date | string
  remark: string
}

const route = useRoute()

const rid = Number(route.params.rid)
const bid = Number(route.params.bid)
const room = reactive({} as Room);
const building = reactive({} as Building);
const buildingList = ref<Building[]>([]) // 存储从API获取的数据

const loadBuildingList = async () => {
  buildingList.value = (await axios.get('/api/address/building/findBuildingList')).data
  console.log("楼宇列表：", buildingList.value)
}

const loadBuilding = async (bid: number) => {
  const buildingData = (await axios.get('/api/address/building/getById', {
    params: {bid: bid}
  })).data
  Object.assign(building, buildingData)
  console.log("楼宇信息：", building)
}

const loadRoom = async (rid: number) => {
  const roomData = (await axios.get('/api/address/room/getById', {
    params: {rid: rid}
  })).data
  Object.assign(room, roomData)
  console.log("房间信息：", buildingList.value)
}

onMounted(async () => {
  await loadBuildingList()
  await loadBuilding(bid)
  await loadRoom(rid)
})

const goBack = () => {
  router.back();
}

const onSubmit = () => {
  console.log('submit!')
  room.bid = building.bid
  room.updateTime = new Date()
  axios.put(`/api/address/room/update`, room)
}
</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是角色添加页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>用户管理></el-link>
        <el-link href="/#/user/admin" type="info">角色管理></el-link>
        <el-link disabled>角色修改</el-link>
      </div>
    </el-col>
  </el-row>

  <el-form>
    <el-descriptions title="住房详情" border>
      <el-descriptions-item align="center" label="楼号">
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
      </el-descriptions-item>
      <el-descriptions-item align="center" label="所有者ID">
        <el-input v-model="room.ownerId"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="房号">
        <el-input v-model="room.roomNumber"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="售出时间">
        <el-date-picker
            v-model="room.saleTime"
            type="date"
            placeholder="Pick a day"
            :size="'default'"
        />
      </el-descriptions-item>
      <el-descriptions-item align="center" label="是否已售出">
        <el-switch
            v-model="room.status"
            class="ml-2"
            style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
            :active-value="1"
            :inactive-value="0"
        />
      </el-descriptions-item>
      <el-descriptions-item align="center" label="备注信息">
        <el-input v-model="room.remark"/>
      </el-descriptions-item>
    </el-descriptions>
    <el-form-item>
      <el-button type="primary" @click="onSubmit">提交</el-button>
      <el-button>重置</el-button>
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