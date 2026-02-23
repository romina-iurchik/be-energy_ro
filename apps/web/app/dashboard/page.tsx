"use client"

import { useEffect, useState, useCallback } from "react"
import { useRouter } from "next/navigation"
import { useWallet } from "@/lib/wallet-context"
import { useI18n } from "@/lib/i18n-context"
import { Sidebar } from "@/components/sidebar"
import { DashboardHeader } from "@/components/dashboard-header"
import { BalanceDisplay } from "@/components/balance-display"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { CheckCircle, Send, Zap, User, Copy, Check, Shield, RefreshCw } from "lucide-react"
import { useEnergyToken } from "@/hooks/useEnergyToken"
import { Spinner } from "@/components/ui/spinner"
import { Button } from "@/components/ui/button"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Area, AreaChart, PieChart, Pie, Cell, Legend } from "recharts"
import { mockUser, mockConsumption, mockStock, mockTransactions, mockEnergyRanking, generateIdenticon } from "@/lib/mock-data"

export default function DashboardPage() {
  const { isConnected, userProfile, address } = useWallet()
  const { t } = useI18n()
  const router = useRouter()
  
  // Integración de lógica de balance (Issue #10 + PR #21)
  const { getBalance, isLoading, error } = useEnergyToken()
  const [balance, setBalance] = useState<number | null>(null)

  const loadBalance = useCallback(async () => {
    if (!isConnected || !address) {
      setBalance(null)
      return
    }

    try {
      const balStr = await getBalance(address)
      const balNum = Number.parseFloat(balStr)
      setBalance(Number.isFinite(balNum) ? balNum : 0)
    } catch (err) {
      console.error("Failed to load HDROP balance:", err)
      setBalance(0)
    }
  }, [isConnected, address, getBalance])

  // DEBUG: verificar env vars
  console.log('CONTRACT ADDRESSES:', {
    token: process.env.NEXT_PUBLIC_ENERGY_TOKEN_CONTRACT,
    distribution: process.env.NEXT_PUBLIC_ENERGY_DISTRIBUTION_CONTRACT
  })

  const [copied, setCopied] = useState(false)
  const [userStockKwh, setUserStockKwh] = useState(mockUser.stockKwh)
  const [transactions, setTransactions] = useState(mockTransactions)

  // Datos para el gráfico de torta (Generación vs Consumo)
  const energyDistributionData = [
    { name: "Consumido", value: mockUser.consumptionThisMonth, color: "#0300AB" },
    { name: "Disponible", value: mockUser.generationThisMonth - mockUser.consumptionThisMonth, color: "#059669" },
  ]

  useEffect(() => {
    if (!isConnected) {
      router.push("/")
    } else if (address) {
      loadBalance()
    }
  }, [isConnected, address, router, loadBalance])

  useEffect(() => {
    const savedStockKwh = localStorage.getItem("userStockKwh")
    const savedHistory = localStorage.getItem("transactionHistory")

    if (savedStockKwh) {
      setUserStockKwh(Number.parseFloat(savedStockKwh))
    }
    if (savedHistory) {
      const history = JSON.parse(savedHistory)
      setTransactions(history.slice(0, 3)) // Show only last 3
    }
  }, [])

  const handleCopyAddress = async () => {
    try {
      await navigator.clipboard.writeText(address ?? "")
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (err) {
      console.error("Failed to copy:", err)
    }
  }

  if (!isConnected) return null

  return (
    <div className="min-h-screen bg-background">
      <Sidebar />

      <main className="md:ml-64">
        <DashboardHeader />

        <div className="p-4 md:p-6">
          {userProfile && (
            <Card
              id="user-info-section"
              className="mb-6 border-2 border-primary/20 bg-gradient-to-r from-primary/5 to-accent/5 scroll-mt-4"
            >
              <CardContent className="p-6">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-full bg-gradient-to-br from-primary/20 to-accent/20 flex items-center justify-center overflow-hidden border-2 border-primary/30">
                    {userProfile.avatar ? (
                      <img
                        src={userProfile.avatar || "/placeholder.svg"}
                        alt={userProfile.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <User className="w-8 h-8 text-primary" />
                    )}
                  </div>
                  <div className="flex-1">
                    <h2 className="text-2xl md:text-3xl font-bold text-foreground">
                      {t("dashboard.welcome")} {userProfile.name}!
                    </h2>
                    <div className="flex items-center gap-2">
                      <p className="text-muted-foreground text-sm md:text-base">
                        {address ? `${address.slice(0, 6)}...${address.slice(-4)}` : t("common.noAddress")}
                      </p>
                      
                      {/* Tooltip mejorado - Issue #11 */}
                      <div className="relative flex items-center group">
                        <button
                          onClick={handleCopyAddress}
                          disabled={!address}
                          className={`
                            ml-2 p-1.5 rounded-md transition-all duration-200 active:scale-95
                            ${copied 
                              ? "bg-success/10 text-success" 
                              : "text-muted-foreground hover:text-primary hover:bg-primary/10"}
                          `}
                        >
                          {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                        </button>

                        <span className={`
                          absolute top-full mt-2 left-1/2 -translate-x-1/2
                          text-xs px-2 py-1 rounded-md
                          bg-card border border-border text-foreground
                          shadow-md whitespace-nowrap z-50
                          transition-all duration-200 pointer-events-none
                          ${copied ? "opacity-100 visible" : "opacity-0 invisible group-hover:opacity-100 group-hover:visible"}
                        `}>
                          {copied ? t("common.copied") : t("common.copyAddress")}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Balance Card con estados de Carga/Error - Issue #10 */}
          <Card className="glass-card border-2 border-primary/20 mb-4 md:mb-6">
            <CardHeader>
              <CardTitle className="text-xl md:text-2xl">{t("dashboard.balance")}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {isLoading && (
                <div className="flex items-center gap-2 text-muted-foreground py-4">
                  <Spinner className="size-5" />
                  <span>{t("dashboard.loadingBalance") || "Cargando balance..."}</span>
                </div>
              )}

              {!isLoading && error && (
                <div className="space-y-3 py-2">
                  <p className="text-destructive text-sm">{error}</p>
                  <Button variant="outline" size="sm" onClick={loadBalance} className="gap-2">
                    <RefreshCw className="size-4" />
                    {t("common.retry") || "Reintentar"}
                  </Button>
                </div>
              )}

              {!isLoading && !error && (
                <BalanceDisplay 
                  amount={balance ?? 0} 
                  symbol="HDROP" 
                  fiatValue={mockUser.balanceUSD} 
                />
              )}

              {/* DeFindex Yield Section */}
              {mockUser.defindexEnabled && (
                <div className="mt-6 pt-6 border-t border-border">
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                        <span className="text-white font-bold text-sm">D</span>
                      </div>
                      <div>
                        <h3 className="font-semibold text-sm">DeFindex Yield</h3>
                        <p className="text-xs text-muted-foreground">Generando rendimiento automático</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-2xl font-bold text-success">{mockUser.defindexAPY}%</div>
                      <div className="text-xs text-muted-foreground">APY anual</div>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                    <div className="bg-success/5 border border-success/20 rounded-lg p-3">
                      <p className="text-xs text-muted-foreground mb-1">Interés hoy</p>
                      <p className="text-lg font-bold text-success">+${mockUser.defindexInterestToday.toFixed(3)}</p>
                    </div>
                    <div className="bg-success/5 border border-success/20 rounded-lg p-3">
                      <p className="text-xs text-muted-foreground mb-1">Este mes</p>
                      <p className="text-lg font-bold text-success">+${mockUser.defindexInterestThisMonth.toFixed(2)}</p>
                    </div>
                    <div className="bg-primary/5 border border-primary/20 rounded-lg p-3 col-span-2 md:col-span-1">
                      <p className="text-xs text-muted-foreground mb-1">En vault</p>
                      <p className="text-lg font-bold text-primary">${mockUser.defindexVaultBalance}</p>
                    </div>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>

          {/* kWh Disponibles y Consumo */}
          <div className="grid lg:grid-cols-2 gap-4 md:gap-6 mb-4 md:mb-6">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg md:text-xl">{t("dashboard.availableKwh")}</CardTitle>
                <CardDescription>{t("dashboard.last7days")}</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-2xl md:text-3xl font-bold text-success mb-4">{userStockKwh.toFixed(1)} kWh</div>
                <ResponsiveContainer width="100%" height={200}>
                  <AreaChart data={mockStock}>
                    <defs>
                      <linearGradient id="stockGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="rgb(5, 150, 105)" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="rgb(5, 150, 105)" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" opacity={0.2} />
                    <XAxis dataKey="day" tick={{ fontSize: 12 }} />
                    <YAxis tick={{ fontSize: 12 }} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: "rgb(var(--color-card))",
                        border: "1px solid rgb(var(--color-border))",
                        borderRadius: "8px",
                      }}
                    />
                    <Area
                      type="monotone"
                      dataKey="kwh"
                      stroke="rgb(5, 150, 105)"
                      fill="url(#stockGradient)"
                      strokeWidth={2}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg md:text-xl">{t("dashboard.consumption")}</CardTitle>
                <CardDescription>{t("dashboard.last7days")}</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-2xl md:text-3xl font-bold text-primary mb-4">
                  {mockUser.consumptionThisMonth} kWh
                </div>
                <ResponsiveContainer width="100%" height={200}>
                  <BarChart data={mockConsumption}>
                    <defs>
                      <linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="rgb(3, 0, 171)" stopOpacity={0.9} />
                        <stop offset="95%" stopColor="rgb(141, 232, 242)" stopOpacity={0.7} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" opacity={0.2} />
                    <XAxis dataKey="day" tick={{ fontSize: 12 }} />
                    <YAxis tick={{ fontSize: 12 }} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: "rgb(var(--color-card))",
                        border: "1px solid rgb(var(--color-border))",
                        borderRadius: "8px",
                      }}
                    />
                    <Bar dataKey="kwh" fill="url(#barGradient)" radius={[8, 8, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>

          {/* Ranking y Gráfico de Distribución */}
          <div className="grid lg:grid-cols-2 gap-4 md:gap-6">
            <Card className="glass-card border-2 border-success/20">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="text-xl md:text-2xl">🏆 Ranking de Ahorro</CardTitle>
                  <Shield className="w-5 h-5 text-success" />
                </div>
                <CardDescription>Los más eficientes de la comunidad</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {mockEnergyRanking.map((user, index) => (
                    <div
                      key={user.id}
                      className={`flex items-center gap-3 p-3 rounded-lg transition-all hover:bg-primary/5 ${index < 3 ? "bg-gradient-to-r from-success/10 to-transparent border border-success/20" : ""}`}
                    >
                      <div className="flex-shrink-0 w-8 h-8 flex items-center justify-center">
                        <span className={`font-bold ${index < 3 ? "text-success text-lg" : "text-muted-foreground"}`}>
                          {index + 1}
                        </span>
                      </div>
                      <div
                        className="w-10 h-10 rounded-full flex items-center justify-center text-white font-semibold text-sm border-2 border-white/20"
                        style={{ backgroundColor: generateIdenticon(user.address) }}
                      >
                        {user.name.charAt(0)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <p className="text-sm font-medium truncate">{user.name}</p>
                          {user.zkVerified && <Shield className="w-3 h-3 text-success flex-shrink-0" />}
                        </div>
                        <div className="flex gap-0.5 mt-1">
                          {Array.from({ length: 5 }).map((_, i) => (
                            <span key={i} className={`text-sm ${i < user.stars ? "opacity-100" : "opacity-20 grayscale"}`}>🍃</span>
                          ))}
                        </div>
                      </div>
                      <div className="flex-shrink-0 text-right">
                        <p className="text-sm font-bold text-success">{user.savingsPercent}%</p>
                        <p className="text-xs text-muted-foreground">ahorro</p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card className="glass-card border-2 border-primary/20">
              <CardHeader>
                <CardTitle className="text-xl md:text-2xl">⚡ Distribución Energética</CardTitle>
                <CardDescription>Generación vs Consumo de este mes</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4 mb-4">
                    <div className="text-center p-3 rounded-lg bg-success/10 border border-success/20">
                      <p className="text-sm text-muted-foreground mb-1">Total Generado</p>
                      <p className="text-2xl font-bold text-success">{mockUser.generationThisMonth} kWh</p>
                    </div>
                    <div className="text-center p-3 rounded-lg bg-primary/10 border border-primary/20">
                      <p className="text-sm text-muted-foreground mb-1">Total Consumido</p>
                      <p className="text-2xl font-bold text-primary">{mockUser.consumptionThisMonth} kWh</p>
                    </div>
                  </div>

                  <ResponsiveContainer width="100%" height={280}>
                    <PieChart>
                      <Pie
                        data={energyDistributionData}
                        cx="50%"
                        cy="50%"
                        labelLine={false}
                        label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                        outerRadius={100}
                        dataKey="value"
                      >
                        {energyDistributionData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip
                        contentStyle={{
                          backgroundColor: "rgb(var(--color-card))",
                          border: "1px solid rgb(var(--color-border))",
                          borderRadius: "8px",
                        }}
                        formatter={(value: number) => `${value} kWh`}
                      />
                      <Legend />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </main>
    </div>
  )
}
