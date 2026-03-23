<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {nextTick, onMounted, ref} from 'vue'
import {ElMessage, ElMessageBox, TableInstance} from 'element-plus'


interface JobType {
  jid: number
  jobType: string
  isEdit: boolean
  _originalData?: JobType // ✅ 新增可选属性
}

interface JobTypePage {
  records: JobType[]
  total: number
  size: number
  current: number
  pages: number
}


const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<JobType[]>([])
const jobTypePage = ref<JobTypePage>() // 存储从API获取的数据

const loadJobTypePage = async (page: number | null) => {
  jobTypePage.value = (await axios.get(`/api/repair/jobType/findPage`, {
    params: {page: page}
  })).data;
}

onMounted(async () => {
  await loadJobTypePage(null);
  console.log("工种列表：", jobTypePage.value)
})

const toggleSelection = (rows?: JobType[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: JobType[]) => {
  multipleSelection.value = val
}

// 新增管理用户
const onAdd = async (row: JobType) => {
  await axios.post(`/api/repair/jobType/add`, {
    jobType: row.jobType,
  })
  await loadJobTypePage(null)
  console.log(jobTypePage.value)
}

const onAddItem = () => {
  if (!jobTypePage.value) return;

  // 创建新行对象[1,6](@ref)
  const newRow: JobType = {
    jid: 0, // 临时ID（提交时后端生成）
    jobType: '',
    isEdit: true // 默认进入编辑状态[1](@ref)
  };

  // 将新行插入表格数据首行[6](@ref)
  jobTypePage.value.records.unshift(newRow);

  // 自动滚动到新增行（可选）
  nextTick(() => {
    const tableWrapper = document.querySelector('.el-table__body-wrapper');
    if (tableWrapper) tableWrapper.scrollTop = 0;
  });
}

// 切换编辑状态
const toggleEdit = (row: JobType) => {
  row.isEdit = !row.isEdit
  // 保存原始数据用于取消操作[3](@ref)
  if (row.isEdit) {
    row._originalData = {...row}
  }
}

const onEdit = (row: JobType) => {
  console.log(row)
  axios.put(`/api/repair/jobType/updateById`, {
    jid: row.jid,
    jobType: row.jobType,
  }).then(response => {
    console.log(response)
  })
  row.isEdit = !row.isEdit
}

const cancel = (row: JobType) => {
  if (!jobTypePage.value) return;

  // 获取当前行索引[3](@ref)
  const index = jobTypePage.value.records.findIndex(item =>
      item.jid === row.jid && item.jid === 0 // 通过临时ID定位新增行
  );

  // 移除未提交的临时行[1,3](@ref)
  if (index !== -1) {
    jobTypePage.value.records.splice(index, 1);
  } else {
    // 已有数据的取消逻辑（恢复原始数据）
    Object.assign(row, row._originalData);
    console.log(111)
    row.isEdit = !row.isEdit;
  }
}

const onDelete = (row: JobType) => {
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
      await axios.delete(`/api/repair/jobType/removeById`, {
        params: {jid: row.jid}
      })

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      await loadJobTypePage(null)
      console.log(jobTypePage.value)
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
  loadJobTypePage(val)
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是工种类型管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">报修管理></el-link>
        <el-link disabled type="info">工种管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>

    <el-table
        ref="multipleTableRef"
        :data="jobTypePage?.records"
        row-key="pid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection"/>
      <el-table-column property="jobType" label="工种">
        <template #default="scope">
          <el-input
              v-if="scope.row.isEdit"
              v-model="scope.row.jobType"
          />
          <span v-else>{{ scope.row.jobType }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <template v-if="!scope.row.isEdit && scope.row.jid != 0">
            <el-button link @click="toggleEdit(scope.row)">修改</el-button>
            <el-button link @click="onDelete(scope.row)">删除</el-button>
          </template>
          <template v-else-if="scope.row.isEdit && scope.row.jid != 0">
            <el-button type="success" link @click="onEdit(scope.row)">保存</el-button>
            <el-button link @click="cancel(scope.row)">取消</el-button>
          </template>
          <template v-else-if="scope.row.isEdit && scope.row.jid == 0">
            <el-button type="success" link @click="onAdd(scope.row)">提交</el-button>
            <el-button link @click="cancel(scope.row)">取消</el-button>
          </template>
        </template>
      </el-table-column>
    </el-table>
    <el-button class="mt-4" style="width: 100%" @click="onAddItem">
      新增故障类型
    </el-button>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="jobTypePage?.total" @size-change="handleSizeChange"
                       @current-change="handleCurrentChange"/>
      </div>
    </div>
  </el-card>
</template>

<style scoped>

</style>