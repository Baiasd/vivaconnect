<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, reactive, ref} from 'vue'
import {dayjs, TableInstance} from 'element-plus'
import router from "@/router/router";
import {Search} from "@element-plus/icons-vue";

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

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<RepairOrder[]>([])
const orderPage = ref<OrderPage>() // 存储从API获取的数据
const searchOrderID = ref<number>()

const loadOrderPage = async (page: number | null) => {
  orderPage.value = (await axios.get('/api/repair/repairOrder/findAllRepairOrderPage', {
    params: {
      page: page,
    }
  })).data
}

onMounted(async () => {
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
    name: 'OrderComment',
    params: {rid: row.rid},
  })
}

const onDispatch = (row: RepairOrder) => {
  router.push({
    name: 'OrderDispatch',
    params: {rid: row.rid},
  })
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

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是工单管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">报修管理></el-link>
        <el-link disabled type="info">工单管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>全部工单</h1>
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
      <el-table-column type="selection" width="55"/>
      <el-table-column align="center" property="rid" label="工单编号"/>
      <el-table-column align="center" property="faultType" label="故障类型"/>
      <el-table-column align="center" property="description" label="故障描述" show-overflow-tooltip/>
      <el-table-column align="center" property="createAt" label="创建时间">
        <template #default="scope">
          {{ dayjs(scope.row.createAt).format('YYYY-MM-DD') }}
        </template>
      </el-table-column>
      <el-table-column align="center" property="urgency" label="紧急程度"/>
      <el-table-column align="center" property="status" label="状态"/>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <el-button link @click="onDetail(scope.row)">查看详情</el-button>
          <el-button link @click="onDispatch(scope.row)" v-if="(scope.row.status == '待分配' || scope.row.status == '未完成') && scope.row.urgency == 1">
            派单
          </el-button>
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