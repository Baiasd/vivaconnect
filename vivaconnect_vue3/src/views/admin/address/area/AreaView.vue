<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {nextTick, onMounted, ref} from 'vue'
import {dayjs, ElMessage, ElMessageBox, TableInstance} from 'element-plus'


interface Area {
  aid: number
  areaName: string
  status: string
  createTime: Date | string
  area: number
  isEdit: boolean
  _originalData?: Area // ✅ 新增可选属性


}

interface AreaPage {
  records: Area[]
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Area[]>([])
const areaPage = ref<AreaPage>() // 存储从API获取的数据

const loadAreaPage = async () => {
  areaPage.value = (await axios.get(`/api/address/area/findAreaPage`)).data;
  console.log("区域列表：", areaPage.value)
}

onMounted(async () => {
  await loadAreaPage()
})

const toggleSelection = (rows?: Area[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: Area[]) => {
  multipleSelection.value = val
}

// 新增管理用户
const onAdd = async (row: Area) => {
  await axios.post(`/api/address/area/save`, {
    areaName: row.areaName,
    status: row.status,
    createTime: row.createTime,
    area: row.area,
  })
  await loadAreaPage()
}

const onAddItem = () => {
  if (!areaPage.value) return;

  // 创建新行对象[1,6](@ref)
  const newRow: Area = {
    aid: 0, // 临时ID（提交时后端生成）
    areaName: '',
    status: '',
    createTime: new Date(),
    area: 0,
    isEdit: true // 默认进入编辑状态[1](@ref)
  };

  // 将新行插入表格数据首行[6](@ref)
  areaPage.value.records.unshift(newRow);

  // 自动滚动到新增行（可选）
  nextTick(() => {
    const tableWrapper = document.querySelector('.el-table__body-wrapper');
    if (tableWrapper) tableWrapper.scrollTop = 0;
  });
}

// 切换编辑状态
const toggleEdit = (row: Area) => {
  row.isEdit = !row.isEdit
  // 保存原始数据用于取消操作[3](@ref)
  if (row.isEdit) {
    row._originalData = {...row}
  }
}

const onEdit = (row: Area) => {
  console.log(row)
  axios.put(`/api/address/area/updateById`, {
    aid: row.aid,
    areaName: row.areaName,
    status: row.status,
    createTime: row.createTime,
    area: row.area,
  }).then(response => {
    console.log(response)
  })
  row.isEdit = !row.isEdit
}

const cancel = (row: Area) => {
  if (!areaPage.value) return;

  // 获取当前行索引[3](@ref)
  const index = areaPage.value.records.findIndex(item =>
      item.aid === row.aid && item.aid === 0 // 通过临时ID定位新增行
  );

  // 移除未提交的临时行[1,3](@ref)
  if (index !== -1) {
    areaPage.value.records.splice(index, 1);
  } else {
    // 已有数据的取消逻辑（恢复原始数据）
    Object.assign(row, row._originalData);
    row.isEdit = !row.isEdit;
  }
}

const onDelete = (row: Area) => {
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
      await axios.delete(`/api/address/area/removeById`, {
        params: {aid: row.aid}
      })

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      await loadAreaPage()
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
const handleCurrentChange = async (val: number) => {
  console.log(`current page: ${val}`)
  areaPage.value = (await axios.get('/api/address/area/findAreaPage', {
    params: {page: val}
  })).data

}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是区域管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">地址管理></el-link>
        <el-link disabled type="info">区域管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-table
        ref="multipleTableRef"
        :data="areaPage?.records"
        row-key="pid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" property="areaName" label="区域名称">
        <template #default="scope">
          <el-input
              v-if="scope.row.isEdit"
              v-model="scope.row.areaName"
          />
          <span v-else>{{ scope.row.areaName }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" property="status" label="状态">
        <template #default="scope">
          <el-select
              v-if="scope.row.isEdit"
              v-model="scope.row.status"
              placeholder="Select"
              size="large"
              style="width: 100%"
          >
            <el-option label="启用" value="启用"/>
            <el-option label="停用" value="停用"/>
            <el-option label="在建" value="在建"/>
          </el-select>
        </template>
      </el-table-column>
      <el-table-column align="center" property="createTime" label="建立时间">

        <template #default="scope">
          <el-date-picker
              v-if="scope.row.isEdit"
              v-model="scope.row.createTime"
              type="date"
              placeholder="Pick a day"
              :size="'default'"
          />
          <span v-else>{{ dayjs(scope.row.createTime).format('YYYY-MM-DD') }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" property="area" label="面积">
        <template #default="scope">
          <el-input
              v-if="scope.row.isEdit"
              v-model="scope.row.area"
          />
          <span v-else>{{ scope.row.area }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <template v-if="!scope.row.isEdit && scope.row.aid != 0">
            <el-button link @click="toggleEdit(scope.row)">修改</el-button>
            <el-button link @click="onDelete(scope.row)">删除</el-button>
          </template>
          <template v-else-if="scope.row.isEdit && scope.row.aid != 0">
            <el-button type="success" link @click="onEdit(scope.row)">保存</el-button>
            <el-button link @click="cancel(scope.row)">取消</el-button>
          </template>
          <template v-else-if="scope.row.isEdit && scope.row.aid == 0">
            <el-button type="success" link @click="onAdd(scope.row)">提交</el-button>
            <el-button link @click="cancel(scope.row)">取消</el-button>
          </template>
        </template>
      </el-table-column>
    </el-table>
    <el-button class="mt-4" style="width: 100%" @click="onAddItem">
      新增区域
    </el-button>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="areaPage?.total" @size-change="handleSizeChange"
                       @current-change="handleCurrentChange"/>
      </div>
    </div>
  </el-card>
</template>

<style scoped>

</style>