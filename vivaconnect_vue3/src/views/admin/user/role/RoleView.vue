<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, ref} from 'vue'
import {ElMessage, ElMessageBox, TableInstance} from 'element-plus'
import router from "@/router/router";
import {Plus} from "@element-plus/icons-vue";


interface Role {
  rid: number
  roleName: string
  roleDesc: string
  roleType: string
}

interface RolePage {
  records: Role[]
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Role[]>([])
const rolePage = ref<RolePage>() // 存储从API获取的数据
const page = ref<number>(1)

const toggleSelection = (rows?: Role[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: Role[]) => {
  multipleSelection.value = val
}

const loadRolePage = async (page: number | null) => {
  rolePage.value = (await axios.get('/api/role/findRolePage', {
    params: {
      page: page,
    }
  })).data
}

onMounted(async () => {
  await loadRolePage(null)
  console.log(rolePage.value)
})


// 新增管理用户
const onAdd = () => {
  router.push({path: '/user/role/add'})
}

// 查看详情
const onDetail = (row: Role) => {
  router.push({
    path: '/user/role/detail',
    query: {
      rid: row.rid,
    }
  })
}

const onEdit = (row: Role) => {
  router.push({
    path: '/user/role/edit',
    query: {
      rid: row.rid,
    }
  })
}

const onDelete = (row: Role) => {
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
      await axios.delete(`/api/role/deleteById`, {params: {rid: row.rid}})

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      await loadRolePage(page.value)
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
  page.value = val
  loadRolePage(val)
  console.log(rolePage.value)
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是角色管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">用户管理></el-link>
        <el-link disabled type="info">角色管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-button :icon="Plus" type="primary" @click="onAdd">
      新增
    </el-button>
    <el-table
        ref="multipleTableRef"
        :data="rolePage?.records"
        row-key="rid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" property="roleName" label="角色名称"/>
      <el-table-column align="center" property="roleDesc" label="角色详情"/>
      <el-table-column align="center" property="roleType" label="角色类别"/>
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
        <el-pagination layout="prev, pager, next" :total="rolePage?.total" @size-change="handleSizeChange"
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
