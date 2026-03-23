<script lang="ts" setup>

import {nextTick, onMounted, reactive, ref} from "vue";
import axios from "@/utils/axios.js";
import * as echarts from "echarts";
import {dayjs} from "element-plus";
import {DArrowRight} from "@element-plus/icons-vue";
import router from "@/router/router";

interface Report {
  total: number
  completed: number
  inCompleted: number
  processing: number
  pending: number
  faultTypeStats: FaultTypeStat[]
  areaStats: AreaStat[]
}

interface FaultTypeStat {
  faultType: string
  count: number
}

interface AreaStat {
  areaName: string
  count: number
}

interface Leaderboards {
  username: string
  avgRating: number
}

interface Notice {
  nid: number
  adminId: number
  title: string
  content: string
  createTime: Date | string
  publishTime: Date | string
  expireTime: Date | string
  isTop: boolean
  viewCount: number
}

interface NoticePage {
  records: Notice[]
  total: number
  size: number
  current: number
  pages: number
}

const noticePage = ref<NoticePage>() // 存储从API获取的数据

const dailyReport = reactive({} as Report)
const weeklyReport = reactive({} as Report)
const monthlyReport = reactive({} as Report)
const yearlyReport = reactive({} as Report)
const leaderboards = ref<Leaderboards[]>([])

const loadNoticePage = async () => {
  noticePage.value = (await axios.get('/api/notice/findNoticePage', {
    params: {
      size: 5
    }
  })).data
}

const loadDailyReport = () => {
  axios.get("/api/statistics/generateDailyReport").then((response) => {
    Object.assign(dailyReport, response.data);
    renderReportCharts();
  })
}

const loadWeeklyReport = () => {
  axios.get("/api/statistics/generateWeeklyReport").then((response) => {
    Object.assign(weeklyReport, response.data);
    renderReportCharts();
  })
}

const loadMonthlyReport = () => {
  axios.get("/api/statistics/generateMonthlyReport").then((response) => {
    Object.assign(monthlyReport, response.data);
    renderReportCharts();
  })
}

const loadYearlyReport = () => {
  axios.get("/api/statistics/generateYearlyReport").then((response) => {
    Object.assign(yearlyReport, response.data);
    renderReportCharts();
  })
}

const loadLeaderboards = () => {
  axios.get("/api/statistics/generateLeaderboards").then((response) => {
    leaderboards.value = response.data;
    renderLeaderboard();
  })
}

onMounted(() => {
  loadNoticePage();
  loadDailyReport();
  loadWeeklyReport();
  loadMonthlyReport();
  loadYearlyReport();
  loadLeaderboards();
  // 监听窗口变化，重新渲染图表
  window.addEventListener("resize", () => {
    if (pieChart.value) echarts.getInstanceByDom(pieChart.value)?.resize();
    if (faultTypeChart.value) echarts.getInstanceByDom(faultTypeChart.value)?.resize();
    if (areaChart.value) echarts.getInstanceByDom(areaChart.value)?.resize();
    if (leaderboardChart.value) echarts.getInstanceByDom(leaderboardChart.value)?.resize();
  });
})

const activeReport = ref("daily");
const completionRate = ref(0);

// ECharts 实例引用
const pieChart = ref<HTMLElement | null>(null);
const faultTypeChart = ref<HTMLElement | null>(null);
const areaChart = ref<HTMLElement | null>(null);
const leaderboardChart = ref<HTMLElement | null>(null);

// 获取当前报表数据
const getCurrentReport = () => {
  switch (activeReport.value) {
    case "daily":
      return dailyReport;
    case "weekly":
      return weeklyReport;
    case "monthly":
      return monthlyReport;
    case "yearly":
      return yearlyReport;
    default:
      return dailyReport;
  }
};

// 渲染饼图
const renderPieChart = () => {
  if (!pieChart.value) return;

  // 销毁旧图表实例
  const oldChart = echarts.getInstanceByDom(pieChart.value);
  if (oldChart) {
    oldChart.dispose();
  }


  const report = getCurrentReport();
  const chart = echarts.init(pieChart.value);

  // 计算完成率
  const completed = report.completed || 0;
  const total = completed + (report.inCompleted || 0);
  completionRate.value = total > 0 ? Math.round((completed / total) * 100) : 0;

  // 检查报表数据是否已加载（只要有一个属性存在即可）
  const hasData = report.completed > 0 || report.inCompleted > 0 || report.processing > 0 || report.pending > 0;
  // 如果没有数据，创建一个全灰的占位饼图
  if (!hasData) {
    const option = {
      title: {
        text: '暂无数据',
        left: 'center',
        top: 'center',
        textStyle: {
          fontSize: 16,
          fontWeight: 'normal',
          color: '#999'
        }
      },
      tooltip: {
        show: false
      },
      series: [
        {
          name: "工单状态",
          type: "pie",
          radius: ["40%", "70%"],
          itemStyle: {
            color: "#e0e0e0" // 灰色
          },
          silent: true, // 禁止交互
          data: [
            {value: 1, name: "暂无数据"}
          ]
        }
      ]
    };
    chart.setOption(option);
    return;
  }


  const option = {
    tooltip: {
      trigger: "item",
      formatter: "{a} <br/>{b}: {c} ({d}%)"
    },
    legend: {
      orient: "vertical",
      right: 10,
      top: "center",
      data: ["已完成", "未完成", "处理中", "待分配"]
    },
    series: [
      {
        name: "工单状态",
        type: "pie",
        radius: ["40%", "70%"],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: "#fff",
          borderWidth: 2
        },
        label: {
          show: false,
          position: "center"
        },
        emphasis: {
          label: {
            show: true,
            fontSize: "18",
            fontWeight: "bold"
          }
        },
        labelLine: {
          show: false
        },
        data: [
          {value: report.completed, name: "已完成"},
          {value: report.inCompleted, name: "未完成"},
          {value: report.processing, name: "处理中"},
          {value: report.pending, name: "待分配"}
        ],
        color: ["#36c6d3", "#ed6b75", "#ffb822", "#8950fc"]
      }
    ]
  };

  chart.setOption(option);
};

// 渲染故障类型柱状图
const renderFaultTypeChart = () => {
  if (!faultTypeChart.value) return;

  const report = getCurrentReport();
  const chart = echarts.init(faultTypeChart.value);

  const option = {
    tooltip: {
      trigger: "axis",
      axisPointer: {
        type: "shadow"
      }
    },
    grid: {
      left: "3%",
      right: "4%",
      bottom: "3%",
      containLabel: true
    },
    xAxis: {
      type: "category",
      data: report.faultTypeStats?.map(item => item.faultType) || [],
      axisLabel: {
        interval: 0,
        rotate: 30
      }
    },
    yAxis: {
      type: "value",
      name: "工单数量"
    },
    series: [
      {
        name: "故障类型",
        type: "bar",
        data: report.faultTypeStats?.map(item => item.count) || [],
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            {offset: 0, color: "#83bff6"},
            {offset: 0.5, color: "#188df0"},
            {offset: 1, color: "#188df0"}
          ])
        }
      }
    ]
  };

  chart.setOption(option);
};

// 渲染区域统计柱状图
const renderAreaChart = () => {
  if (!areaChart.value) return;

  const report = getCurrentReport();
  const chart = echarts.init(areaChart.value);

  const option = {
    tooltip: {
      trigger: "axis",
      axisPointer: {
        type: "shadow"
      }
    },
    grid: {
      left: "3%",
      right: "4%",
      bottom: "3%",
      containLabel: true
    },
    xAxis: {
      type: "category",
      data: report.areaStats?.map(item => item.areaName) || [],
      axisLabel: {
        interval: 0,
        rotate: 30
      }
    },
    yAxis: {
      type: "value",
      name: "工单数量"
    },
    series: [
      {
        name: "区域工单",
        type: "bar",
        data: report.areaStats?.map(item => item.count) || [],
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            {offset: 0, color: "#47C363"},
            {offset: 0.5, color: "#1E9E2F"},
            {offset: 1, color: "#1E9E2F"}
          ])
        }
      }
    ]
  };

  chart.setOption(option);
};

// 修改排行榜渲染函数
const renderLeaderboard = () => {
  if (!leaderboardChart.value || !leaderboards.value) return;

  const chart = echarts.getInstanceByDom(leaderboardChart.value);
  if (chart) {
    chart.dispose(); // 销毁旧实例
  }

  const newChart = echarts.init(leaderboardChart.value);

  // 确保数据存在且有效
  const leaderboardData = leaderboards.value || [];

  const top20 = leaderboardData.slice(0, 20); // 取前10名

  const reverseData = [...top20].reverse()
  // 如果没有数据，显示空状态
  if (reverseData.length === 0) {
    newChart.setOption({
      title: {
        text: '暂无数据',
        left: 'center',
        top: 'center',
        textStyle: {
          fontSize: 16,
          fontWeight: 'normal'
        }
      }
    });
    return;
  }

  const option = {
    tooltip: {
      trigger: "axis",
      axisPointer: {
        type: "shadow"
      },
      formatter: "{b}: {c}分"
    },
    grid: {
      left: "3%",
      right: "4%",
      bottom: "3%",
      top: "3%",
      containLabel: true
    },
    xAxis: {
      type: "value",
      min: 0,
      max: 5,
      axisLabel: {
        formatter: "{value}分"
      }
    },
    yAxis: {
      type: "category",
      data: reverseData.map(item => item.username),
      axisLabel: {
        interval: 0
      }
    },
    series: [
      {
        name: "平均评分",
        type: "bar",
        data: reverseData.map(item => item.avgRating),
        label: {
          show: true,
          position: "right",
          formatter: "{c}分"
        },
        itemStyle: {
          color: function (params: any) {
            // 根据排名设置不同颜色
            const colorList = [
              "#795548",  // 20
              "#F44336",  // 19
              "#E91E63",  // 18
              "#9C27B0",  // 17
              "#673AB7",  // 16
              "#3F51B5",  // 15
              "#2196F3",  // 14
              "#03A9F4",  // 13
              "#00BCD4",  // 12
              "#009688",  // 11
              "#4CAF50",  // 10
              "#8BC34A",  // 9
              "#CDDC39",  // 8
              "#FFEB3B",  // 7
              "#FFC107",  // 6
              "#FF8E53",  // 5
              "#FF6B6B",  // 4
              "#CD7F32",  // 铜牌 (3)
              "#C0C0C0",  // 银牌 (2)
              "#FFD700"   // 金牌 (1)
            ];
            return colorList[params.dataIndex] || "#36c6d3";
          }
        }
      }
    ]
  };

  newChart.setOption(option);
};

// 渲染所有图表
const renderReportCharts = () => {
  nextTick(() => {
    renderPieChart();
    renderFaultTypeChart();
    renderAreaChart();
  });
};

</script>

<template>
  <el-row :gutter="20" justify="space-around">
    <el-col :span="14">
      <el-card style="margin-bottom: 10px">
        <!-- 报表选择器 -->
        <template #header>
          <div class="card-header">
            <span style="font-weight: bolder;font-size: 20px">社区故障统计</span>
          </div>
        </template>

        <el-radio-group v-model="activeReport" @change="renderReportCharts">
          <el-radio-button label="daily">日报表</el-radio-button>
          <el-radio-button label="weekly">周报表</el-radio-button>
          <el-radio-button label="monthly">月报表</el-radio-button>
          <el-radio-button label="yearly">年报表</el-radio-button>
        </el-radio-group>
      </el-card>

      <el-card style="margin-bottom: 10px">
        <!-- 工单状态饼图 -->
        <template #header>
          <div class="card-header">
            <span style="font-weight: bolder;font-size: 20px">工单状态分布 (完成率: {{ completionRate }}%)</span>
          </div>
        </template>
        <div ref="pieChart" style="width: 100%; height: 300px;"></div>
      </el-card>

      <el-card style="margin-bottom: 10px">
        <!-- 故障类型和区域统计柱状图 -->
        <template #header>
          <div class="card-header">
            <span style="font-weight: bolder;font-size: 20px">故障类型统计</span>
          </div>
        </template>
        <div ref="faultTypeChart" style="width: 100%; height: 300px;"></div>
      </el-card>
      <el-card>
        <template #header>
          <div class="card-header">
            <span style="font-weight: bolder;font-size: 20px">区域工单统计</span>
          </div>
        </template>
        <div ref="areaChart" style="width: 100%; height: 300px;"></div>
      </el-card>

    </el-col>
    <el-col :span="10">
      <!-- 公告板 -->
      <el-card style="margin-bottom: 10px">
        <template #header>
          <el-row justify="space-between">
            <el-col :span="4">
              <span style="font-weight: bolder;font-size: 20px">社区公告</span>
            </el-col>
            <el-col :span="2">
              <el-button @click="router.push({name: 'NoticePage'})" text>更多<el-icon><DArrowRight /></el-icon></el-button>
            </el-col>
          </el-row>
          <div class="card-header">


          </div>
        </template>
        <el-table
            ref="multipleTableRef"
            :data="noticePage?.records"
            row-key="nid"
            style="width: 100%"
        >
          <el-table-column align="center" property="publishTime" label="发布时间">
            <template #default="scope">
                    <span v-if="scope.row.publishTime != null">
                      {{ dayjs(scope.row.publishTime).format('YYYY-MM-DD') }}
                    </span>
              <span v-else>永久</span>
            </template>
          </el-table-column>
          <el-table-column align="center" property="title" label="标题" show-overflow-tooltip>
            <template #default="scope">
              <router-link :to="{ name: 'DetailNotice', params: { nid: scope.row.nid }}">{{
                  scope.row.title
                }}
              </router-link>
            </template>
          </el-table-column>

          <el-table-column align="center" property="viewCount" label="浏览量">
            <template #default="scope">
              <span v-if="scope.row.viewCount == null">0</span>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-card>
        <!-- 维修工排行榜 -->
        <template #header>
          <div class="card-header">
            <span style="font-weight: bolder;font-size: 20px">维修工评分排行榜</span>
          </div>
        </template>
        <div ref="leaderboardChart" style="width: 100%; min-height: 900px;"></div>
      </el-card>
    </el-col>
  </el-row>
</template>

<style scoped>

</style>