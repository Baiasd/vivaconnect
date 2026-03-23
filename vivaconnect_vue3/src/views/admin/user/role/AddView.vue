<script lang="ts" setup>
import {useRouter} from 'vue-router'
import {reactive, ref, watch} from 'vue'
import type {TableInstance} from 'element-plus'
import {CollapseModelValue} from 'element-plus'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";

const router = useRouter()

interface Role {
  rid: number
  roleName: string
  roleDesc: string
  roleType: string
  permissions: Permission[]
}

interface Permission {
  pid: number
  permissionName: string
  permissionDesc: string
  permissionType: string
}

const role = reactive({} as Role);
const permissionList = ref<Permission[]>([])
const pids = ref<number[]>([])

const loadPermissionList = (async (permissionType) => {
  // 获取角色列表
  permissionList.value = (await axios.get(`/api/user/permission/findPermissionListByType`, {
    params: {permissionType: permissionType}
  })).data;
  console.log("权限列表：", permissionList.value)
})


// 监听角色类别变化
watch(() => role.roleType, (newVal) => {
  loadPermissionList(newVal)
  console.log(role)
});

const activeNames = ref(['1'])
const handleChange = (val: CollapseModelValue) => {
  console.log(val)
}


const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Permission[]>([])

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
  pids.value = val.map(item => item.pid)
  console.log("pids:", pids.value)
}


const goBack = () => {
  router.back();
}


const onSubmit_Basic = () => {
  console.log('submit!')
  axios.post(`/api/role/add`, role).then(data => {
    Object.assign(role, data.data)
  })
}

const onSubmit_Permission = () => {
  console.log('submit!')
  axios.put(`/api/role/updatePermissionsById`, {
    rid: role.rid,
    pids: pids.value
  }).then(data => {
    console.log(data)
  })
}
</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是角色添加页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>用户管理></el-link>
        <el-link href="/#/user/admin" type="info">角色管理></el-link>
        <el-link disabled>角色修改</el-link>
      </div>
    </el-col>
  </el-row>


  <div class="demo-collapse" style="min-height: 60vh">
    <el-collapse v-model="activeNames" @change="handleChange">
      <el-collapse-item title="角色详情" name="1">

        <el-form>
          <el-descriptions border>
            <el-descriptions-item align="center" label="角色名称" width="240px">
              <el-input v-model="role.roleName"/>
            </el-descriptions-item>
            <el-descriptions-item align="center" label="角色详情" width="240px">
              <el-input v-model="role.roleDesc"/>
            </el-descriptions-item>
            <el-descriptions-item align="center" label="角色类型">
              <el-select
                  v-model="role.roleType"
                  placeholder="Select"
                  size="large"
                  style="width: 100%"
              >
                <el-option label="业主" value="业主"/>
                <el-option label="维修工" value="维修工"/>
                <el-option label="管理员" value="管理员"/>
              </el-select>
            </el-descriptions-item>

          </el-descriptions>
          <el-form-item>
            <el-button type="primary" @click="onSubmit_Basic">提交</el-button>
            <el-button>重置</el-button>
          </el-form-item>
        </el-form>


      </el-collapse-item>
      <el-collapse-item title="权限列表" name="2">
        <el-form>
          <el-table
              ref="multipleTableRef"
              :data="permissionList"
              row-key="id"
              style="width: 100%"
              @selection-change="handleSelectionChange"
          >
            <el-table-column type="selection" width="55"/>
            <el-table-column property="permissionName" label="权限名称" width="120"/>
            <el-table-column property="permissionDesc" label="权限描述"/>
            <el-table-column property="permissionType" label="权限分类"/>
          </el-table>
          <div style="margin-top: 20px">
            <el-button @click="toggleSelection()">清空</el-button>
          </div>
          <el-form-item>
            <el-button type="primary" @click="onSubmit_Permission">提交</el-button>
            <el-button>重置</el-button>
          </el-form-item>
        </el-form>

      </el-collapse-item>
    </el-collapse>
  </div>
</template>

<style scoped>
.avatar-uploader .el-upload {
  border: 1px dashed var(--el-border-color);
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: var(--el-transition-duration-fast);
}

.avatar-uploader .el-upload:hover {
  border-color: var(--el-color-primary);
}

.el-icon.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
}
</style>