<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, reactive, ref} from 'vue'
import {dayjs, ElMessage, ElMessageBox, TableInstance} from 'element-plus'
import router from "@/router/router";
import {Plus} from "@element-plus/icons-vue";

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
  commentId: number
  faultType: string
  description: string
  address: string
  status: string
  urgency: number
  images: []
  materials: []
  cost: number
  createAt: string
  assignedAt: string
  completedAt: string
}

interface OrderPage {
  records: RepairOrder[]
  total: number
  size: number
  current: number
  pages: number
}

const user = reactive({} as User)
const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<RepairOrder[]>([])
const orderPage = ref<OrderPage>() // 存储从API获取的数据

const loadUser = (async () => {
  const userData = (await axios.get('/api/user/CurrentUserWithNoPermission')).data
  Object.assign(user, userData)
  console.log("用户信息：", user)
})

const loadOrderPage = async (page: number | null) => {
  orderPage.value = (await axios.get('/api/repair/repairOrder/findOwnerOrderPage', {
    params: {
      page: page,
      uid: user.uid
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


// 新增通知
const onAdd = () => {
  router.push({
    name: 'AddOrder'
  })
}

// 查看详情
const onDetail = (row: RepairOrder) => {
  router.push({
    name: 'OrderDetail',
    params: {rid: row.rid},
  })
}

const onEdit = (row: RepairOrder) => {
  if (row.status === '草稿' || row.status === '待分配') {
    router.push({
      name: 'EditOrder',
      params: {
        rid: row.rid
      },
    })
  }
}

const onComment = (row: RepairOrder) => {
  console.log(row.rid)
  console.log(row.commentId)
  if (row.status === '已完成' || row.status === '未完成') {
    router.push({
      name: 'CommentOrder',
      params: {
        cid: row.commentId,
        uid: user.uid
      },
    })
  }
}

const onDelete = (row: RepairOrder) => {
  // 1. 添加确认弹窗（网页2、4）
  ElMessageBox.confirm(
      '此操作将永久删除该管理员，是否继续？',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
  ).then(async () => {
    try {
      // 2. 发送删除请求（需要传递ID参数）
      await axios.delete(`/api/repair/repairOrder/deleteById`, {
        params: {rid: row.rid}
      })

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      await loadOrderPage(null)
    } catch (error) {
      // 5. 错误处理（网页6）
      ElMessage.error('删除失败：' + error.message)
    }
  }).catch(() => {
    // 用户点击取消时的提示（网页4）
    ElMessage.info('已取消删除')
  })
}

const handleSizeChange = (val: number) => {
  console.log(`${val} items per page`)
}
const handleCurrentChange = (val: number) => {
  console.log(`current page: ${val}`)
  loadOrderPage(val)
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是报修页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">报修></el-link>
        <el-link disabled type="info">订单记录</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-button :icon="Plus" type="primary" @click="onAdd">
      我要报修
    </el-button>
    <el-table
        ref="multipleTableRef"
        :data="orderPage?.records"
        row-key="nid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" property="rid" label="订单编号"/>
      <el-table-column align="center" property="faultType" label="故障类型"/>
      <el-table-column align="center" property="description" label="故障描述" show-overflow-tooltip/>
      <el-table-column align="center" property="createAt" label="创建时间">
        <template #default="scope">
          {{ dayjs(scope.row.createAt).format('YYYY-MM-DD') }}
        </template>
      </el-table-column>
      <el-table-column align="center" property="status" label="状态"/>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <el-button link @click="onDetail(scope.row)">查看详情</el-button>
          <el-button link @click="onEdit(scope.row)" v-if="scope.row.status == '草稿' || scope.row.status == '待分配'">
            修改
          </el-button>
          <el-button link @click="onComment(scope.row)" v-if="scope.row.status == '已完成' || scope.row.status == '未完成'">
            评价
          </el-button>
          <el-button link @click="onDelete(scope.row)" v-if="scope.row.status == '草稿' || scope.row.status == '待分配'">删除</el-button>
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