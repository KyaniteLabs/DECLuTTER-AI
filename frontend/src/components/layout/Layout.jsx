import { Outlet, Link, useLocation } from 'react-router-dom'
import { Home, Search, Users, MessageCircle } from 'lucide-react'

export function Layout() {
  const location = useLocation()

  const navigation = [
    { name: 'Home', href: '/', icon: Home },
    { name: 'Find', href: '/posts', icon: Search },
    { name: 'Pods', href: '/pods', icon: Users },
    { name: 'Shifts', href: '/shifts', icon: MessageCircle },
  ]

  const isActive = (path) => {
    if (path === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(path)
  }

  return (
    <div className="flex h-screen flex-col">
      {/* Header */}
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="text-2xl">🤝</div>
              <h1 className="text-xl font-bold text-gray-900">CommunityCircle</h1>
            </div>
            <nav className="hidden md:flex items-center gap-6">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  to={item.href}
                  className={`flex items-center gap-2 text-sm font-medium transition-colors ${
                    isActive(item.href)
                      ? 'text-primary-600'
                      : 'text-gray-600 hover:text-gray-900'
                  }`}
                >
                  <item.icon size={20} />
                  {item.name}
                </Link>
              ))}
            </nav>
            <div className="flex items-center gap-4">
              <button className="text-gray-600 hover:text-gray-900">
                <span className="sr-only">Notifications</span>
                🔔
              </button>
              <button className="text-gray-600 hover:text-gray-900">
                <span className="sr-only">Profile</span>
                👤
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main content */}
      <main className="flex-1 overflow-y-auto bg-gray-50">
        <Outlet />
      </main>

      {/* Mobile bottom navigation */}
      <nav className="border-t border-gray-200 bg-white md:hidden">
        <div className="flex items-center justify-around py-2">
          {navigation.map((item) => (
            <Link
              key={item.name}
              to={item.href}
              className={`flex flex-col items-center gap-1 px-3 py-2 text-xs ${
                isActive(item.href)
                  ? 'text-primary-600'
                  : 'text-gray-600'
              }`}
            >
              <item.icon size={24} />
              <span>{item.name}</span>
            </Link>
          ))}
        </div>
      </nav>
    </div>
  )
}
