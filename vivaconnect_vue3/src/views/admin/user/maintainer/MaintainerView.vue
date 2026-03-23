<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, ref} from 'vue'
import {ElMessage, ElMessageBox, TableInstance} from 'element-plus'
import router from "@/router/router";


interface User {
  uid: number
  username: string
  phone: string
  email: string
}

interface MaintainerPage {
  records: User[]
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<User[]>([])
const maintainerPage = ref<MaintainerPage>() // 存储从API获取的数据

const toggleSelection = (rows?: User[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: User[]) => {
  multipleSelection.value = val
}


onMounted(() => {
  axios.get('/api/user/findMaintainerPage').then(data => {
    maintainerPage.value = data.data;
    console.log(maintainerPage.value)
    console.log(data.data)
    if (maintainerPage.value?.records) {
      maintainerPage.value.records = maintainerPage.value.records.map(maintainer => ({
        ...maintainer,
        phone: desensitizePhone(maintainer.phone),
        email: desensitizeEmail(maintainer.email)
      }))
    }
  })
  console.log(maintainerPage.value)

})

const desensitizePhone = (phone: string) => {
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

const desensitizeEmail = (email: string) => {
  const [local, domain] = email.split('@')
  if (local.length <= 4) return email // 短邮箱不处理
  return local.slice(0, 2) + '****' + local.slice(-2) + '@' + domain
}

// 查看详情
const onDetail = (row: User) => {
  router.push({
    name: 'MaintainerDetail',
    params: {
      uid: row.uid,
    }
  })
}

const onDelete = (row: User) => {
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
      await axios.delete(`/api/user/delete?uid=${row.uid}`)

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      const res = await axios.get('/api/user/findMaintainerPage')
      maintainerPage.value = res.data.records
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
  axios.get('/api/user/findMaintainerPage', {
    params: {page: val}
  }).then(data => {
    maintainerPage.value = data.data;
    console.log(maintainerPage.value)
    console.log(data.data)
  })
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是维修工管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>用户管理></el-link>
        <el-link disabled>维修工管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-table
        ref="multipleTableRef"
        :data="maintainerPage?.records"
        row-key="mid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" property="username" label="维修工名称"/>
      <el-table-column align="center" property="phone" label="手机号"/>
      <el-table-column align="center" property="email" label="邮箱"/>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <el-button link @click="onDetail(scope.row)">查看详情</el-button>
          <el-button link @click="onDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="maintainerPage?.total" @size-change="handleSizeChange"
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
