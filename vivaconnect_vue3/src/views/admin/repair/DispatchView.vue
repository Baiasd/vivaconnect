<script setup lang="ts">


import {computed, onMounted, reactive, ref} from "vue";
import {useRoute} from "vue-router";
import axios from "@/utils/axios";
import router from "@/router/router";
import {ArrowLeft} from "@element-plus/icons-vue";
import {dayjs, TableInstance} from "element-plus";


interface RepairOrder {
  rid: number
  ownerId: number
  maintainerId: number
  commentId: number
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
  createAt: Date | string
  assignedAt: Date | string
  completedAt: Date | string
}

interface FaultType {
  fid: number
  faultType: string
  jobType: string
}

interface Maintainer {
  mid: number
  realName: string
  idCard: string
  gender: string
  birthday: Date | string
  age: number
  jobType: string
  salary: number
  Certificate_of_skill: string
  status: string
}

const route = useRoute()
const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<RepairOrder[]>([])

const rid = Number(route.params.rid)
const repairOrder = reactive<RepairOrder>({images: [] as { url: string }[]} as RepairOrder);
const faultType = reactive({} as FaultType);
const maintainerList = ref<Maintainer[]>([]);


const loadRepairOrder = async () => {
  const orderData = (await axios.get(`/api/repair/repairOrder/findById`, {
    params: {rid: rid}
  })).data
  Object.assign(repairOrder, orderData)
  console.log("订单信息：", orderData)
  console.log(repairOrder.images?.[0].url)
}

const loadFaultType = async () => {
  const faultTypeData = (await axios.get(`/api/repair/faultType/findByType`, {
    params: {type: repairOrder.faultType}
  })).data
  Object.assign(faultType, faultTypeData)
}

const loadMaintainerList = async () => {
  console.log(faultType.jobType)
  maintainerList.value = (await axios.get(`/api/user/maintainer/findListByJobType`, {
    params: {jobType: faultType.jobType}
  })).data
}


onMounted(async () => {
  await loadRepairOrder()
  await loadFaultType()
  await loadMaintainerList();
  console.log(maintainerList)
})
const handleSelectionChange = (val: RepairOrder[]) => {
  multipleSelection.value = val
}

const imageUrlList = computed(() =>
    repairOrder.images?.map(img => img.url) || []
);

const onDispatch = async (row: Maintainer) => {
  await axios.get(`/api/user/findByMid`, {
    params: {mid: row.mid}
  }).then(res => {
    console.log(res.data)
    repairOrder.maintainerId = res.data.uid
  })

  repairOrder.status = "处理中"
  repairOrder.assignedAt = new Date()
  row.status = "在忙"
  await axios.put(`/api/repair/repairOrder/updateById`, repairOrder)
  await axios.put(`/api/user/maintainer/updateById`, row)
  console.log(row)
  console.log(repairOrder)
  await loadMaintainerList()
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
        <h1>这是派单页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">报修管理></el-link>
        <el-link href="/#/user/repair/order" type="info">工单管理管理></el-link>
        <el-link disabled type="info">派单</el-link>
      </div>
    </el-col>
  </el-row>

  <el-descriptions title="通知详情" :column="5" border>
    <el-descriptions-item align="center" label="故障类型">{{ repairOrder.faultType }}</el-descriptions-item>
    <el-descriptions-item align="center" label="地址">{{
        repairOrder.areaName + repairOrder.buildingName + "栋" + repairOrder.roomNumber + "间"
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="创建时间">{{
        dayjs(repairOrder.createAt).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="分配时间">{{
        dayjs(repairOrder.assignedAt).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="完成时间">{{
        dayjs(repairOrder.completedAt).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="问题描述">{{ repairOrder.description }}</el-descriptions-item>

    <el-descriptions-item align="center" label="故障图片">
      <label>点看查看所有图片</label>
      <el-image
          style="width: 200px; height: 200px"
          :src="repairOrder.images?.[0].url"
          :zoom-rate="1.2"
          :max-scale="7"
          :min-scale="0.2"
          :preview-src-list="imageUrlList"
          show-progress
          :initial-index="4"
          fit="cover"
          v-if="repairOrder.images?.length"
      />
    </el-descriptions-item>
  </el-descriptions>
  <el-table
      ref="multipleTableRef"
      :data="maintainerList"
      row-key="id"
      style="width: 100%"
      @selection-change="handleSelectionChange"
  >
    <el-table-column type="selection" width="55"/>
    <el-table-column property="realName" label="姓名"/>
    <el-table-column property="jobType" label="工种"/>
    <el-table-column property="status" label="状态"/>
    <el-table-column align="center" label="操作">
      <template #default="scope">
        <el-button type="primary" @click="onDispatch(scope.row)" v-if="scope.row.status != '在忙'">派单</el-button>
      </template>
    </el-table-column>
  </el-table>
</template>

<style scoped>

</style>