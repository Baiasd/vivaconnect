<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, ref} from 'vue'
import {ElMessage, ElMessageBox, TableInstance} from 'element-plus'
import router from "@/router/router";
import {Plus} from "@element-plus/icons-vue";


interface Admin {
  uid: number
  username: string
  phone: string
  email: string
}

interface AdminPage {
  records: Admin[];
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Admin[]>([])
const adminPage = ref<AdminPage>() // 存储从API获取的数据

const toggleSelection = (rows?: Admin[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: Admin[]) => {
  multipleSelection.value = val
}


const loadAdminPage = async () => {
  adminPage.value = (await axios.get('/api/user/findAdminPage')).data

  if (adminPage.value?.records) {
    adminPage.value.records = adminPage.value.records.map(admin => ({
      ...admin,
      phone: desensitizePhone(admin.phone),
      email: desensitizeEmail(admin.email)
    }))
  }
}

onMounted(async () => {
  await loadAdminPage()
  console.log(adminPage.value)

})


const desensitizePhone = (phone: string) => {
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

const desensitizeEmail = (email: string) => {
  const [local, domain] = email.split('@')
  if (local.length <= 4) return email // 短邮箱不处理
  return local.slice(0, 2) + '****' + local.slice(-2) + '@' + domain
}


// 新增管理用户
const onAdd = () => {
  router.push({path: '/user/admin/add'})
}

// 查看详情
const onDetail = (row: Admin) => {
  router.push({
    name: 'AdminDetail',
    params: {
      uid: row.uid,
    }
  })
}

const onEdit = (row: Admin) => {
  router.push({
    name: 'EditAdmin',
    params: {
      uid: row.uid,
    }
  })
}

const onDelete = (row: Admin) => {
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
      await axios.delete(`/api/user/deleteById?uid=${row.uid}`)

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      const res = await axios.get('/api/user/findAdminPage')
      adminPage.value = res.data.records
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
  axios.get('/api/user/findAdminPage', {
    params: {page: val}
  }).then(data => {
    adminPage.value = data.data;
    console.log(adminPage.value)
    console.log(data.data)
  })
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是管理员管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">用户管理></el-link>
        <el-link disabled type="info">管理员管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-button :icon="Plus" type="primary" @click="onAdd">
      新增
    </el-button>
    <el-table
        ref="multipleTableRef"
        :data="adminPage?.records"
        row-key="uid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55"/>
      <el-table-column property="username" label="管理员名称" width="120"/>
      <el-table-column property="phone" label="手机号" width="120"/>
      <el-table-column property="email" label="邮箱"/>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <el-button link @click="onDetail(scope.row)">查看详情</el-button>
          <el-button link @click="onEdit(scope.row)">修改</el-button>
          <el-button link @click="onDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="adminPage?.total" @size-change="handleSizeChange"
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
