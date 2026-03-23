<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, reactive, ref} from 'vue'
import {dayjs, TableInstance} from 'element-plus'
import router from "@/router/router";
import {ArrowLeft, Search} from "@element-plus/icons-vue";

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
  maintainer: Maintainer
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

interface RepairOrder {
  rid: number
  ownerId: number
  maintainerId: number
  faultType: string
  description: string
  address: string
  status: string
  urgency: number
  images: []
  materials: []
  cost: number
  createAt: Date | string
  assignedAt: Date | string
  completedAt: Date | string
}

interface OrderPage {
  records: RepairOrder[]
  total: number
  size: number
  current: number
  pages: number
}

const user = reactive({} as User)
const maintainer = reactive({} as Maintainer)
const searchOrderID = ref<number>()

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<RepairOrder[]>([])
const orderPage = ref<OrderPage>() // 存储从API获取的数据

const loadUser = (async () => {
  const userData = (await axios.get('/api/user/CurrentUserWithNoPermission')).data
  Object.assign(user, userData)
  Object.assign(maintainer, userData.maintainer)
  console.log("用户信息：", user)
  console.log("维修工信息：", userData.maintainer)
})

const loadOrderPage = async (page: number | null) => {
  orderPage.value = (await axios.get('/api/repair/repairOrder/findMaintainerOrderPage', {
    params: {
      uid: user.uid,
      page: page
    }
  })).data
  console.log(orderPage.value)
}

onMounted(async () => {
  await loadUser()
  await loadOrderPage(null)
})

const toggleSelection = (rows?: RepairOrder[], ignoreSelectable?: boolean) => {
  if (rows) {
    rows.forEach((row) => {
      multipleTableRef.value!.toggleRowSelection(
          row,
          undefined,
          ignoreSelectable
      )
    })
  } else {
    multipleTableRef.value!.clearSelection()
  }
}
const handleSelectionChange = (val: RepairOrder[]) => {
  multipleSelection.value = val
}


// 查看详情
const onDetail = (row: RepairOrder) => {
  router.push({
    name: 'OrderDetail',
    params: {rid: row.rid},
  })
}

const onCompleted = (row: RepairOrder) => {
  row.status = "已完成"
  row.completedAt = new Date()
  console.log(row)
  axios.put(`/api/repair/repairOrder/updateById`, row)
  updateMaintainerStatus()
}

const onIncomplete = (row: RepairOrder) => {
  row.status = "未完成"
  console.log(row)
  axios.put(`/api/repair/repairOrder/updateById`, row)
  updateMaintainerStatus()
}

const updateMaintainerStatus = () => {
  maintainer.status = "空闲"
  axios.put(`/api/user/maintainer/updateById`, maintainer)
}


const handleSizeChange = (val: number) => {
  console.log(`${val} items per page`)
}
const handleCurrentChange = (val: number) => {
  console.log(`current page: ${val}`)
  loadOrderPage(val)
}

const searchOrder = () => {
  router.push({
    name: 'OrderDetail',
    params: {rid: searchOrderID.value},
  })
}

const goBack = () => {
  router.back();
}
</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle" style="margin-top: 20px">
    <el-col :span="20">
      <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">报修></el-link>
        <el-link disabled type="info">已接单</el-link>
      </div>
    </el-col>
  </el-row>


  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>已接工单</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <el-input
          v-model="searchOrderID"
          style="max-width: 600px; height: 40px"
          placeholder="请输入工单ID"
          class="input-with-select"
      >
        <template #append>
          <el-button @click="searchOrder" :icon="Search" />
        </template>
      </el-input>
    </el-col>
  </el-row>

  <el-card>
    <el-table
        ref="multipleTableRef"
        :data="orderPage?.records"
        row-key="nid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" property="faultType" label="故障类型"/>
      <el-table-column align="center" property="description" label="故障描述" show-overflow-tooltip/>
      <el-table-column align="center" property="createAt" label="创建时间">
        <template #default="scope">
          {{ dayjs(scope.row.createAt).format('YYYY-MM-DD hh:mm:ss') }}
        </template>
      </el-table-column>
      <el-table-column align="center" property="createAt" label="接单时间">
        <template #default="scope">
          {{ dayjs(scope.row.assignedAt).format('YYYY-MM-DD hh:mm:ss') }}
        </template>
      </el-table-column>
      <el-table-column align="center" property="status" label="状态"/>
      <el-table-column align="center" property="createAt" label="完成时间">
        <template #default="scope">
          {{ dayjs(scope.row.completedAt).format('YYYY-MM-DD hh:mm:ss') }}
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <el-button link @click="onDetail(scope.row)">查看详情</el-button>
          <el-button link @click="onCompleted(scope.row)" v-if="scope.row.status === '处理中'">已完成</el-button>
          <el-button link @click="onIncomplete(scope.row)" v-if="scope.row.status === '处理中'">未完成</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="orderPage?.total" @size-change="handleSizeChange"
                       @current-change="handleCurrentChange"/>
      </div>
    </div>
  </el-card>

</template>


<style scoped>
.example-pagination-block + .example-pagination-block {
  margin-top: 10px;
}

.example-pagination-block .example-demonstration {
  margin-bottom: 16px;
}
</style>