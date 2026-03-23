<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {nextTick, onMounted, ref, watch} from 'vue'
import {ElMessage, ElMessageBox, TableInstance} from 'element-plus'


interface Permission {
  pid: number
  permissionName: string
  permissionDesc: string
  permissionType: string
  isEdit: boolean
  _originalData?: Permission // ✅ 新增可选属性
}

interface PermissionPage {
  records: Permission[]
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Permission[]>([])
const permissionPage = ref<PermissionPage>() // 存储从API获取的数据
const currentPermissionType = ref<string>('全部权限')
const page = ref<number>(1)

onMounted(async () => {
  permissionPage.value = (await axios.get(`/api/user/permission/findPermissionPage`)).data;
  console.log("权限列表：", permissionPage.value)
})

const toggleSelection = (rows?: Permission[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: Permission[]) => {
  multipleSelection.value = val
}

const updatePermissionPage = (async (permissionType: string | null) => {
  permissionPage.value = (await axios.get(`/api/user/permission/findPermissionPageByType`, {
    params: {
      page: page.value,
      permissionType: permissionType
    }
  })).data;
})

// 监听筛选条件变化（用防抖控制）
watch(currentPermissionType, (async (newVal) => {
  if (!newVal) return;
  await updatePermissionPage(newVal);
}));


// 新增管理用户
const onAdd = async (row: Permission) => {
  await axios.post(`/api/user/permission/save`, {
    permissionName: row.permissionName,
    permissionDesc: row.permissionDesc,
    permissionType: row.permissionType,
  })
  await updatePermissionPage(currentPermissionType.value)
  console.log(permissionPage.value)
}

const onAddItem = () => {
  if (!permissionPage.value) return;

  // 创建新行对象[1,6](@ref)
  const newRow: Permission = {
    pid: 0, // 临时ID（提交时后端生成）
    permissionName: '',
    permissionDesc: '',
    permissionType: '所有角色',
    isEdit: true // 默认进入编辑状态[1](@ref)
  };

  // 将新行插入表格数据首行[6](@ref)
  permissionPage.value.records.unshift(newRow);

  // 自动滚动到新增行（可选）
  nextTick(() => {
    const tableWrapper = document.querySelector('.el-table__body-wrapper');
    if (tableWrapper) tableWrapper.scrollTop = 0;
  });
}

// 切换编辑状态
const toggleEdit = (row: Permission) => {
  row.isEdit = !row.isEdit
  // 保存原始数据用于取消操作[3](@ref)
  if (row.isEdit) {
    row._originalData = {...row}
  }
}

const onEdit = (row: Permission) => {
  console.log(row)
  axios.put(`/api/user/permission/updateById`, {
    pid: row.pid,
    permissionName: row.permissionName,
    permissionDesc: row.permissionDesc,
    permissionType: row.permissionType,
  }).then(response => {
    console.log(response)
  })
  row.isEdit = !row.isEdit
}

const cancel = (row: Permission) => {
  if (!permissionPage.value) return;

  // 获取当前行索引[3](@ref)
  const index = permissionPage.value.records.findIndex(item =>
      item.pid === row.pid && item.pid === 0 // 通过临时ID定位新增行
  );

  // 移除未提交的临时行[1,3](@ref)
  if (index !== -1) {
    permissionPage.value.records.splice(index, 1);
  } else {
    // 已有数据的取消逻辑（恢复原始数据）
    Object.assign(row, row._originalData);
    console.log(111)
    row.isEdit = !row.isEdit;
  }
}

const onDelete = (row: Permission) => {
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
      await axios.delete(`/api/user/permission/removeById`,{
        params: {pid: row.pid}
      })

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      await updatePermissionPage(currentPermissionType.value)
      console.log(permissionPage.value)
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
  axios.get('/api/user/permission/findPermissionPage', {
    params: {page: val}
  }).then(data => {
    permissionPage.value = data.data;
    console.log(permissionPage.value)
    console.log(data.data)
  })
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是权限管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">用户管理></el-link>
        <el-link disabled type="info">权限管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-row class="row-bg" justify="space-between">
      <el-col :span="4">
        <div class="grid-content ep-bg-purple-light"/>
        <el-select
            v-model="currentPermissionType"
            placeholder="Select"
            size="large"
            style="width: 100%"
        >
          <el-option label="全部权限" value="全部权限"/>
          <el-option label="业主" value="业主"/>
          <el-option label="维修工" value="维修工"/>
          <el-option label="管理员" value="管理员"/>
          <el-option label="所有角色" value="所有角色"/>
        </el-select>
      </el-col>
    </el-row>


    <el-table
        ref="multipleTableRef"
        :data="permissionPage?.records"
        row-key="pid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55"/>
      <el-table-column property="permissionName" label="权限名称">
        <template #default="scope">
          <el-input
              v-if="scope.row.isEdit"
              v-model="scope.row.permissionName"
          />
          <span v-else>{{ scope.row.permissionName }}</span>
        </template>
      </el-table-column>
      <el-table-column property="permissionDesc" label="权限描述">
        <template #default="scope">
          <el-input
              v-if="scope.row.isEdit"
              v-model="scope.row.permissionDesc"
          />
          <span v-else>{{ scope.row.permissionDesc }}</span>
        </template>
      </el-table-column>
      <el-table-column property="permissionType" label="权限类别">
        <template #default="scope">
          <el-select
              v-if="scope.row.isEdit"
              v-model="scope.row.permissionType"
              placeholder="Select"
              size="large"
              style="width: 100%"
          >
            <el-option label="业主" value="业主"/>
            <el-option label="维修工" value="维修工"/>
            <el-option label="管理员" value="管理员"/>
            <el-option label="所有角色" value="所有角色"/>
          </el-select>
          <span v-else>{{ scope.row.permissionType }}</span>
        </template>

      </el-table-column>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <template v-if="!scope.row.isEdit && scope.row.pid != 0">
            <el-button link @click="toggleEdit(scope.row)">修改</el-button>
            <el-button link @click="onDelete(scope.row)">删除</el-button>
          </template>
          <template v-else-if="scope.row.isEdit && scope.row.pid != 0">
            <el-button type="success" link @click="onEdit(scope.row)">保存</el-button>
            <el-button link @click="cancel(scope.row)">取消</el-button>
          </template>
          <template v-else-if="scope.row.isEdit && scope.row.pid == 0">
            <el-button type="success" link @click="onAdd(scope.row)">提交</el-button>
            <el-button link @click="cancel(scope.row)">取消</el-button>
          </template>
        </template>
      </el-table-column>
    </el-table>
    <el-button class="mt-4" style="width: 100%" @click="onAddItem">
      新增权限
    </el-button>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="permissionPage?.total" @size-change="handleSizeChange"
                       @current-change="handleCurrentChange"/>
      </div>
    </div>
  </el-card>
</template>

<style scoped>

</style>