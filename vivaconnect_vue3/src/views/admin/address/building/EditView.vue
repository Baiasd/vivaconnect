<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onMounted, reactive, ref, watch} from 'vue'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";

const router = useRouter()

interface Area {
  aid: number
  areaName: string
  status: string
  createTime: Date | string
  area: number
}

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

const route = useRoute()

const bid = Number(route.params.bid)
const building = reactive({} as Building);
const originBuilding = reactive({} as Building);
const area = reactive({} as Area);
const areaList = ref<Area[]>([]) // 存储从API获取的数据

const loadAreaList = async () => {
  areaList.value = await (await axios.get('/api/address/area/findAreaList')).data
  console.log("区域列表：", areaList.value)
}

const loadBuilding = async (bid: number) => {
  const buildingData = (await axios.get('/api/address/building/getById', {
    params: {bid: bid}
  })).data
  Object.assign(building, buildingData)
  Object.assign(originBuilding, buildingData)
  console.log("楼宇信息：", building)
}

const loadArea = async (aid: number) => {
  const areaData = (await axios.get('/api/address/area/getById', {
    params: {aid: aid}
  })).data
  Object.assign(area, areaData)
  console.log("区域信息：", area)
}

onMounted(async () => {
  await loadAreaList()
  await loadBuilding(bid)
  await loadArea(building.aid)
})

watch(() => area.areaName, (newArea) => {
  const selectArea = areaList.value.find(area => area.areaName === newArea)
  if (selectArea) {
    Object.assign(area, selectArea)
  }
})

const goBack = () => {
  router.back();
}


const onSubmit = () => {
  console.log('submit!')
  building.aid = area.aid
  axios.put(`/api/address/building/update`, building)
}

const onReset = () => {
  Object.assign(building, originBuilding)
}
</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是楼宇修改页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>地址管理></el-link>
        <el-link href="/#/user/address/building" type="info">楼宇管理></el-link>
        <el-link disabled>楼信息修改</el-link>
      </div>
    </el-col>
  </el-row>

  <el-form>
    <el-descriptions title="楼宇详情" column="5" border>
      <el-descriptions-item align="center" label="区域">
        <el-select
            v-model="area.areaName"
            placeholder="Select"
            size="large"
            style="width: 100%"
        >
          <el-option
              v-for="item in areaList"
              :key="item.aid"
              :label="item.areaName"
              :value="item.areaName"
          />
        </el-select>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="楼号">
        <el-input v-model="building.buildingName"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="总楼层数">
        <el-input v-model="building.floorTotal"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="地上层数">
        <el-input v-model="building.floorGround"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="地下层数">
        <el-input v-model="building.floorUnderground"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="电梯数量">
        <el-input v-model="building.elevatorCount"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="用途">
        <el-input v-model="building.buildingPurpose"/>
      </el-descriptions-item>

      <el-descriptions-item align="center" label="消防状态">
        <el-select
            v-model="building.fireSystemStatus"
            placeholder="Select"
            size="large"
            style="width: 100%"
        >
          <el-option label="正常" value="正常"/>
          <el-option label="异常" value="异常"/>
          <el-option label="未知" value="未知"/>
        </el-select>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="建筑面积">
        <el-input v-model="building.totalArea"/>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="建成时间">
        <el-date-picker
            v-model="building.constructionTime"
            type="date"
            placeholder="Pick a day"
            :size="'default'"
        />
      </el-descriptions-item>
      <el-descriptions-item align="center" label="封闭式管理">
        <el-switch
            v-model="building.isClosed"
            class="ml-2"
            style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
            :active-value="1"
            :inactive-value="0"
        />
      </el-descriptions-item>
    </el-descriptions>
    <el-form-item>
      <el-button type="primary" @click="onSubmit">提交</el-button>
      <el-button @click="onReset">重置</el-button>
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