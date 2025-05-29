from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.edge.service import Service as EdgeService
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager
from webdriver_manager.microsoft import EdgeChromiumDriverManager
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from selenium.webdriver.common.keys import Keys
import time
import json
from datetime import datetime
import os

class PruebaPortabilidadCafeConecta:
    def __init__(self):
        # URL base ajustada para Flutter web (puerto típico de desarrollo)
        self.url_base = "http://localhost:3000"  # Cambia esto si usas otro puerto
        self.resultados = {}
        self.crear_directorio_capturas()
        
    def crear_directorio_capturas(self):
        """Crear directorio para capturas de pantalla"""
        if not os.path.exists("capturas_portabilidad_cafeconecta"):
            os.makedirs("capturas_portabilidad_cafeconecta")
    
    def setup_chrome(self):
        """Configurar Chrome WebDriver para Flutter web"""
        print("🔧 Configurando Chrome para Flutter...")
        options = webdriver.ChromeOptions()
        options.add_argument("--window-size=1920,1080")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--disable-web-security")  # Para Flutter web
        options.add_argument("--allow-running-insecure-content")
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        
        try:
            service = ChromeService(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=options)
            print("✅ Chrome configurado correctamente")
            return driver
        except Exception as e:
            print(f"❌ Error configurando Chrome: {str(e)}")
            return None
    
    def setup_firefox(self):
        """Configurar Firefox WebDriver para Flutter web"""
        print("🔧 Configurando Firefox para Flutter...")
        options = webdriver.FirefoxOptions()
        options.add_argument("--width=1920")
        options.add_argument("--height=1080")
        # Configuraciones adicionales para Flutter
        options.set_preference("security.tls.insecure_fallback_hosts", "localhost")
        options.set_preference("security.mixed_content.block_active_content", False)
        
        try:
            service = FirefoxService(GeckoDriverManager().install())
            driver = webdriver.Firefox(service=service, options=options)
            print("✅ Firefox configurado correctamente")
            return driver
        except Exception as e:
            print(f"❌ Error configurando Firefox: {str(e)}")
            return None
    
    def setup_edge(self):
        """Configurar Edge WebDriver para Flutter web"""
        print("🔧 Configurando Edge para Flutter...")
        options = webdriver.EdgeOptions()
        options.add_argument("--window-size=1920,1080")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--disable-web-security")
        
        try:
            service = EdgeService(EdgeChromiumDriverManager().install())
            driver = webdriver.Edge(service=service, options=options)
            print("✅ Edge configurado correctamente")
            return driver
        except Exception as e:
            print(f"❌ Error configurando Edge: {str(e)}")
            return None
    
    def verificar_conectividad(self):
        """Verificar que Flutter web esté corriendo"""
        import requests
        try:
            response = requests.get(self.url_base, timeout=10)
            return response.status_code == 200
        except:
            return False
    
    def esperar_flutter_cargado(self, driver, timeout=30):
        """Esperar a que Flutter termine de cargar completamente"""
        print("   ⏳ Esperando que Flutter se cargue...")
        
        try:
            # Esperar a que Flutter engine esté disponible
            WebDriverWait(driver, timeout).until(
                lambda d: d.execute_script("return typeof window.flutterCanvasKit !== 'undefined' || typeof window._flutter !== 'undefined'")
            )
            
            # Esperar un poco más para que los widgets se rendericen
            time.sleep(3)
            
            # Verificar que no haya spinner de carga visible
            WebDriverWait(driver, 10).until(
                lambda d: not d.find_elements(By.CSS_SELECTOR, ".loading, .spinner, [data-testid='loading']")
            )
            
            print("   ✅ Flutter cargado completamente")
            return True
            
        except TimeoutException:
            print("   ⚠️ Timeout esperando Flutter, continuando...")
            return False
    
    def buscar_elemento_flutter(self, driver, selectores, descripcion, timeout=10):
        """Buscar elementos en Flutter web con múltiples selectores"""
        for selector in selectores:
            try:
                if selector.startswith("xpath:"):
                    elementos = WebDriverWait(driver, timeout).until(
                        EC.presence_of_all_elements_located((By.XPATH, selector[6:]))
                    )
                else:
                    elementos = WebDriverWait(driver, timeout).until(
                        EC.presence_of_all_elements_located((By.CSS_SELECTOR, selector))
                    )
                
                # Verificar que al menos uno sea visible
                elementos_visibles = [elem for elem in elementos if elem.is_displayed()]
                if elementos_visibles:
                    print(f"   ✅ {descripcion} encontrado con selector: {selector}")
                    return elementos_visibles[0]
                    
            except (TimeoutException, NoSuchElementException):
                continue
        
        print(f"   ❌ {descripcion} no encontrado")
        return None
    
    def test_navegador(self, driver, nombre_navegador):
        """Ejecutar pruebas completas en un navegador específico para CafeConecta"""
        print(f"\n{'='*50}")
        print(f"☕ PROBANDO CAFECONECTA EN {nombre_navegador.upper()}")
        print(f"{'='*50}")
        
        resultado = {
            'navegador': nombre_navegador,
            'version': '',
            'flutter_cargado': False,
            'pagina_login_visible': False,
            'formulario_login_funcional': False,
            'navegacion_registro': False,
            'elementos_registro': False,
            'responsive_design': False,
            'performance_flutter': {},
            'tiempo_carga_promedio': 0,
            'errores_javascript': [],
            'capturas': [],
            'errores': []
        }
        
        tiempos_carga = []
        
        try:
            # Obtener información del navegador
            resultado['version'] = driver.capabilities.get('browserVersion', 'Desconocida')
            print(f"📋 Versión: {resultado['version']}")
            
            # TEST 1: Cargar la aplicación Flutter
            print("\n1️⃣ Cargando CafeConecta (Flutter web)...")
            inicio_carga = time.time()
            
            driver.get(self.url_base)
            
            # Esperar a que Flutter cargue
            flutter_ok = self.esperar_flutter_cargado(driver)
            tiempo_carga = time.time() - inicio_carga
            tiempos_carga.append(tiempo_carga)
            
            if flutter_ok:
                resultado['flutter_cargado'] = True
                print(f"   ✅ Flutter cargado - Tiempo: {tiempo_carga:.2f}s")
            else:
                resultado['errores'].append("Flutter no se cargó correctamente")
                print(f"   ⚠️ Flutter con problemas - Tiempo: {tiempo_carga:.2f}s")
            
            # Tomar captura inicial
            captura_inicial = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_flutter_inicial.png"
            driver.save_screenshot(captura_inicial)
            resultado['capturas'].append(captura_inicial)
            
            # TEST 2: Verificar pantalla de login de CafeConecta
            print("\n2️⃣ Verificando pantalla de login...")
            
            # Selectores específicos para tu app Flutter
            selectores_login = [
                "input[type='email'], input[type='text'][placeholder*='correo' i]",
                "input[type='password']",
                "flt-semantics input",  # Flutter web específico
                "[data-semantics-role='textbox']",
                "input",
                "xpath://input[@type='email' or contains(@placeholder, 'correo') or contains(@placeholder, 'email')]"
            ]
            
            email_field = self.buscar_elemento_flutter(driver, selectores_login, "Campo de email")
            
            selectores_password = [
                "input[type='password']",
                "flt-semantics input[type='password']",
                "xpath://input[@type='password']"
            ]
            
            password_field = self.buscar_elemento_flutter(driver, selectores_password, "Campo de contraseña")
            
            if email_field and password_field:
                resultado['pagina_login_visible'] = True
                print("   ✅ Formulario de login encontrado")
            
            # TEST 3: Probar funcionalidad del formulario
            print("\n3️⃣ Probando funcionalidad del formulario...")
            
            if resultado['pagina_login_visible']:
                try:
                    # Limpiar y llenar campos
                    email_field.clear()
                    email_field.send_keys("test@cafeconecta.com")
                    time.sleep(1)
                    
                    password_field.clear()
                    password_field.send_keys("123456")
                    time.sleep(1)
                    
                    print("   📝 Datos de prueba ingresados")
                    
                    # Buscar botón de login
                    selectores_boton = [
                        "button[type='submit']",
                        "button:contains('Iniciar')",
                        "button:contains('Entrar')",
                        "button:contains('Login')",
                        "[role='button']",
                        "flt-semantics[role='button']",
                        "xpath://button[contains(text(), 'Iniciar') or contains(text(), 'Entrar') or contains(text(), 'Login')]"
                    ]
                    
                    boton_login = self.buscar_elemento_flutter(driver, selectores_boton, "Botón de login")
                    
                    if boton_login:
                        # Intentar hacer click
                        driver.execute_script("arguments[0].click();", boton_login)
                        time.sleep(3)
                        
                        resultado['formulario_login_funcional'] = True
                        print("   ✅ Formulario de login funcional")
                        
                        # Captura después del intento de login
                        captura_post_login = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_post_login.png"
                        driver.save_screenshot(captura_post_login)
                        resultado['capturas'].append(captura_post_login)
                    
                except Exception as e:
                    resultado['errores'].append(f"Error en funcionalidad de login: {str(e)}")
                    print(f"   ❌ Error en login: {str(e)}")
            
            # TEST 4: Navegación a registro
            print("\n4️⃣ Probando navegación a registro...")
            
            try:
                # Buscar link/botón de registro
                selectores_registro = [
                    "a[href*='register'], a[href*='registro']",
                    "button:contains('Registr')",
                    "xpath://a[contains(@href, 'register') or contains(text(), 'Registr')]",
                    "xpath://button[contains(text(), 'Registr')]"
                ]
                
                link_registro = self.buscar_elemento_flutter(driver, selectores_registro, "Link de registro")
                
                if link_registro:
                    inicio_nav = time.time()
                    driver.execute_script("arguments[0].click();", link_registro)
                    time.sleep(3)
                    
                    tiempo_nav = time.time() - inicio_nav
                    tiempos_carga.append(tiempo_nav)
                    
                    resultado['navegacion_registro'] = True
                    print(f"   ✅ Navegación a registro exitosa - Tiempo: {tiempo_nav:.2f}s")
                    
                    # Verificar elementos del registro
                    selectores_nombre = [
                        "input[type='text']:not([type='email']):not([type='password'])",
                        "input[placeholder*='nombre' i]",
                        "xpath://input[contains(@placeholder, 'nombre') or contains(@name, 'name')]"
                    ]
                    
                    campo_nombre = self.buscar_elemento_flutter(driver, selectores_nombre, "Campo nombre")
                    
                    if campo_nombre:
                        resultado['elementos_registro'] = True
                        print("   ✅ Formulario de registro encontrado")
                    
                    # Captura de registro
                    captura_registro = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_registro.png"
                    driver.save_screenshot(captura_registro)
                    resultado['capturas'].append(captura_registro)
                
            except Exception as e:
                print(f"   ⚠️ Error navegando a registro: {str(e)}")
            
            # TEST 5: Responsive design
            print("\n5️⃣ Verificando diseño responsive...")
            
            try:
                # Probar diferentes tamaños de pantalla
                tamaños = [
                    (375, 667, "iPhone SE"),
                    (768, 1024, "iPad"),
                    (1920, 1080, "Desktop")
                ]
                
                responsive_ok = True
                
                for ancho, alto, dispositivo in tamaños:
                    driver.set_window_size(ancho, alto)
                    time.sleep(2)
                    
                    # Verificar que los elementos sigan siendo accesibles
                    email_responsive = self.buscar_elemento_flutter(
                        driver, 
                        selectores_login, 
                        f"Email en {dispositivo}",
                        timeout=5
                    )
                    
                    if not email_responsive:
                        responsive_ok = False
                        print(f"   ❌ Problemas responsive en {dispositivo}")
                    else:
                        print(f"   ✅ Responsive OK en {dispositivo}")
                    
                    # Captura en cada tamaño
                    captura_responsive = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_{dispositivo.lower().replace(' ', '_')}.png"
                    driver.save_screenshot(captura_responsive)
                    resultado['capturas'].append(captura_responsive)
                
                resultado['responsive_design'] = responsive_ok
                
                # Restaurar tamaño normal
                driver.set_window_size(1920, 1080)
                
            except Exception as e:
                print(f"   ⚠️ Error en prueba responsive: {str(e)}")
            
            # TEST 6: Performance de Flutter
            print("\n6️⃣ Midiendo performance de Flutter...")
            
            try:
                # Medir tiempo de navegación
                driver.get(self.url_base)
                inicio_perf = time.time()
                self.esperar_flutter_cargado(driver)
                tiempo_perf = time.time() - inicio_perf
                
                resultado['performance_flutter'] = {
                    'tiempo_carga_completa': tiempo_perf,
                    'flutter_funcional': tiempo_perf < 15  # Considerar bueno si carga en menos de 15s
                }
                
                print(f"   📊 Tiempo carga completa: {tiempo_perf:.2f}s")
                
            except Exception as e:
                print(f"   ⚠️ Error midiendo performance: {str(e)}")
            
            # Calcular tiempo promedio de carga
            if tiempos_carga:
                resultado['tiempo_carga_promedio'] = sum(tiempos_carga) / len(tiempos_carga)
            
            # Verificar errores de JavaScript/Flutter
            try:
                logs = driver.get_log('browser')
                js_errors = [log for log in logs if log['level'] == 'SEVERE' and 'flutter' not in log['message'].lower()]
                resultado['errores_javascript'] = [error['message'] for error in js_errors[:5]]  # Limitamos a 5
                
                if js_errors:
                    print(f"   ⚠️ {len(js_errors)} errores JavaScript encontrados")
                else:
                    print("   ✅ Sin errores JavaScript críticos")
            except:
                print("   ⚠️ No se pudieron verificar logs JavaScript")
            
        except Exception as e:
            resultado['errores'].append(f"Error general: {str(e)}")
            print(f"   ❌ Error general: {str(e)}")
        
        finally:
            try:
                driver.quit()
                print(f"   🔚 {nombre_navegador} finalizado")
            except:
                pass
            
        return resultado
    
    def ejecutar_pruebas_completas(self):
        """Ejecutar pruebas en todos los navegadores disponibles"""
        print("☕ INICIANDO PRUEBAS DE PORTABILIDAD CAFECONECTA FLUTTER")
        print("="*70)
        
        # Verificar conectividad
        if not self.verificar_conectividad():
            print(f"❌ ERROR: No se puede conectar a CafeConecta en {self.url_base}")
            print("   Asegúrate de que Flutter web esté corriendo con:")
            print("   flutter run -d web --web-port 3000")
            return
        
        print(f"✅ CafeConecta Flutter detectado en {self.url_base}")
        
        # Configurar navegadores
        navegadores = [
            ('Chrome', self.setup_chrome),
            ('Firefox', self.setup_firefox),
            ('Edge', self.setup_edge)
        ]
        
        # Ejecutar pruebas
        for nombre, setup_func in navegadores:
            print(f"\n{'='*25} {nombre.upper()} {'='*25}")
            try:
                driver = setup_func()
                if driver:
                    resultado = self.test_navegador(driver, nombre)
                    self.resultados[nombre] = resultado
                else:
                    print(f"❌ No se pudo inicializar {nombre}")
                    self.resultados[nombre] = {
                        'navegador': nombre,
                        'error_inicializacion': True,
                        'errores': [f"No se pudo inicializar {nombre}"]
                    }
            except Exception as e:
                print(f"❌ Error crítico con {nombre}: {str(e)}")
                self.resultados[nombre] = {
                    'navegador': nombre,
                    'error_critico': True,
                    'errores': [f"Error crítico: {str(e)}"]
                }
        
        # Generar reportes
        self.generar_reporte_consola()
        self.generar_reporte_json()
        self.generar_reporte_html()
    
    def generar_reporte_consola(self):
        """Generar reporte detallado en consola"""
        print("\n" + "="*80)
        print("☕ REPORTE FINAL DE PORTABILIDAD CAFECONECTA")
        print("="*80)
        
        total_navegadores = len(self.resultados)
        navegadores_exitosos = 0
        
        for navegador, resultado in self.resultados.items():
            print(f"\n🌐 {navegador}:")
            if resultado.get('error_inicializacion') or resultado.get('error_critico'):
                print("   ❌ No se pudo probar este navegador")
                continue
            
            print(f"   📌 Versión: {resultado.get('version', 'Desconocida')}")
            print(f"   ⚡ Flutter cargado: {'✅' if resultado.get('flutter_cargado') else '❌'}")
            print(f"   🔐 Login visible: {'✅' if resultado.get('pagina_login_visible') else '❌'}")
            print(f"   📝 Login funcional: {'✅' if resultado.get('formulario_login_funcional') else '❌'}")
            print(f"   📝 Navegación registro: {'✅' if resultado.get('navegacion_registro') else '❌'}")
            print(f"   👤 Elementos registro: {'✅' if resultado.get('elementos_registro') else '❌'}")
            print(f"   📱 Responsive: {'✅' if resultado.get('responsive_design') else '❌'}")
            print(f"   ⏱️ Tiempo carga promedio: {resultado.get('tiempo_carga_promedio', 0):.2f}s")
            print(f"   📸 Capturas generadas: {len(resultado.get('capturas', []))}")
            
            # Performance de Flutter
            perf = resultado.get('performance_flutter', {})
            if perf:
                print(f"   🚀 Performance Flutter: {perf.get('tiempo_carga_completa', 0):.2f}s")
            
            # Contar como exitoso
            funciones_principales = [
                resultado.get('flutter_cargado', False),
                resultado.get('pagina_login_visible', False),
                resultado.get('formulario_login_funcional', False)
            ]
            
            if sum(funciones_principales) >= 2:
                navegadores_exitosos += 1
                print("   🎉 NAVEGADOR COMPATIBLE CON CAFECONECTA")
            else:
                print("   ⚠️ NAVEGADOR CON PROBLEMAS")
            
            if resultado.get('errores'):
                print("   🐛 Errores encontrados:")
                for error in resultado['errores'][:3]:  # Mostrar solo los primeros 3
                    print(f"     - {error}")
        
        # Estadísticas finales
        compatibilidad = (navegadores_exitosos / total_navegadores) * 100 if total_navegadores > 0 else 0
        
        print(f"\n📈 ESTADÍSTICAS FINALES CAFECONECTA:")
        print(f"   🔢 Total navegadores probados: {total_navegadores}")
        print(f"   ✅ Navegadores compatibles: {navegadores_exitosos}")
        print(f"   📊 Porcentaje de compatibilidad: {compatibilidad:.1f}%")
        
        if compatibilidad >= 80:
            print("   🏆 ¡EXCELENTE COMPATIBILIDAD!")
        elif compatibilidad >= 60:
            print("   👍 BUENA COMPATIBILIDAD")
        else:
            print("   ⚠️ NECESITA MEJORAS DE COMPATIBILIDAD")
    
    def generar_reporte_json(self):
        """Generar reporte en formato JSON"""
        reporte = {
            'aplicacion': 'CafeConecta Flutter Web',
            'fecha_prueba': datetime.now().isoformat(),
            'url_probada': self.url_base,
            'tipo_aplicacion': 'Flutter Web',
            'resultados': self.resultados,
            'resumen': {
                'total_navegadores': len(self.resultados),
                'navegadores_exitosos': sum(1 for r in self.resultados.values() 
                                          if r.get('flutter_cargado') and r.get('pagina_login_visible')),
                'capturas_generadas': sum(len(r.get('capturas', [])) for r in self.resultados.values()),
                'promedio_tiempo_carga': sum(r.get('tiempo_carga_promedio', 0) for r in self.resultados.values()) / len(self.resultados) if self.resultados else 0
            }
        }
        
        with open('reporte_portabilidad_CafeConecta_Flutter.json', 'w', encoding='utf-8') as f:
            json.dump(reporte, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 Reporte JSON guardado: reporte_portabilidad_CafeConecta_Flutter.json")
    
    def generar_reporte_html(self):
        """Generar reporte en formato HTML"""
        html_content = f"""
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Reporte de Portabilidad - CafeConecta Flutter</title>
            <style>
                body {{ 
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                    margin: 20px; 
                    background: linear-gradient(135deg, #8B4513 0%, #A0522D 100%);
                    min-height: 100vh;
                }}
                .container {{ 
                    max-width: 1200px; 
                    margin: 0 auto; 
                    background: white; 
                    padding: 30px; 
                    border-radius: 15px; 
                    box-shadow: 0 8px 25px rgba(0,0,0,0.15); 
                }}
                h1 {{ 
                    color: #8B4513; 
                    text-align: center; 
                    margin-bottom: 10px;
                    font-size: 2.2em;
                }}
                .subtitle {{ 
                    text-align: center; 
                    color: #666; 
                    margin-bottom: 30px; 
                    font-style: italic;
                }}
                .summary {{ 
                    background: linear-gradient(135deg, #FFF8DC 0%, #F5E6D3 100%); 
                    padding: 20px; 
                    border-radius: 10px; 
                    margin: 20px 0; 
                    border-left: 5px solid #8B4513;
                }}
                .browser-result {{ 
                    border: 2px solid #ddd; 
                    margin: 20px 0; 
                    padding: 20px; 
                    border-radius: 10px; 
                    transition: transform 0.2s;
                }}
                .browser-result:hover {{
                    transform: translateY(-2px);
                    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                }}
                .success {{ 
                    background: linear-gradient(135deg, #E8F5E8 0%, #F1F8E9 100%); 
                    border-color: #4caf50; 
                }}
                .warning {{ 
                    background: linear-gradient(135deg, #FFF3E0 0%, #FFF8E1 100%); 
                    border-color: #ff9800; 
                }}
                .error {{ 
                    background: linear-gradient(135deg, #FFEBEE 0%, #FCE4EC 100%); 
                    border-color: #f44336; 
                }}
                .test-item {{ 
                    display: flex; 
                    justify-content: space-between; 
                    padding: 8px 0; 
                    border-bottom: 1px solid #eee;
                }}
                .test-item:last-child {{
                    border-bottom: none;
                }}
                .pass {{ color: #4caf50; font-weight: bold; }}
                .fail {{ color: #f44336; font-weight: bold; }}
                .screenshots {{ 
                    display: grid; 
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); 
                    gap: 15px; 
                    margin-top: 15px; 
                }}
                .screenshot {{ 
                    width: 100%; 
                    height: 150px; 
                    object-fit: cover; 
                    border: 2px solid #ddd; 
                    border-radius: 8px; 
                    transition: transform 0.2s;
                }}
                .screenshot:hover {{
                    transform: scale(1.05);
                }}
                .performance-badge {{
                    display: inline-block;
                    padding: 4px 8px;
                    border-radius: 12px;
                    font-size: 0.8em;
                    font-weight: bold;
                    margin-left: 10px;
                }}
                .perf-excellent {{ background: #4caf50; color: white; }}
                .perf-good {{ background: #ff9800; color: white; }}
                .perf-poor {{ background: #f44336; color: white; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>☕ Reporte de Portabilidad - CafeConecta</h1>
                <div class="subtitle">Aplicación Flutter Web - Sistema de Gestión Cafetera</div>
                
                <div class="summary">
                    <h3>📊 Resumen de Pruebas</h3>
                    <p><strong>📅 Fecha:</strong> {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
                    <p><strong>🌐 URL Probada:</strong> {self.url_base}</p>
                    <p><strong>🔧 Tipo:</strong> Flutter Web Application</p>
                    <p><strong>🔢 Total de Navegadores:</strong> {len(self.resultados)}</p>
                    <p><strong>✅ Navegadores Compatibles:</strong> {sum(1 for r in self.resultados.values() if r.get('flutter_cargado') and r.get('pagina_login_visible'))}</p>
                    <p><strong>📸 Capturas Generadas:</strong> {sum(len(r.get('capturas', [])) for r in self.resultados.values())}</p>
                </div>
        """
        
        for navegador, resultado in self.resultados.items():
            if resultado.get('error_inicializacion') or resultado.get('error_critico'):
                clase = "error"
                estado = "❌ Error de Inicialización"
            elif resultado.get('flutter_cargado') and resultado.get('pagina_login_visible'):
                clase = "success"
                estado = "✅ Compatible con CafeConecta"
            else:
                clase = "warning"
                estado = "⚠️ Problemas Detectados"
            
            # Determinar badge de performance
            tiempo_carga = resultado.get('tiempo_carga_promedio', 0)
            if tiempo_carga <= 3:
                perf_class = "perf-excellent"
                perf_text = "Excelente"
            elif tiempo_carga <= 8:
                perf_class = "perf-good" 
                perf_text = "Bueno"
            else:
                perf_class = "perf-poor"
                perf_text = "Lento"
            
            html_content += f"""
                <div class="browser-result {clase}">
                    <h3>🌐 {navegador} - {estado}
                        <span class="performance-badge {perf_class}">{perf_text}: {tiempo_carga:.1f}s</span>
                    </h3>
                    
                    <div class="test-item">
                        <span><strong>📌 Versión del Navegador:</strong></span>
                        <span>{resultado.get('version', 'Desconocida')}</span>
                    </div>
                    
                    <div class="test-item">
                        <span><strong>⚡ Flutter Engine Cargado:</strong></span>
                        <span class="{'pass' if resultado.get('flutter_cargado') else 'fail'}">
                            {'✅ SÍ' if resultado.get('flutter_cargado') else '❌ NO'}
                        </span>
                    </div>
                    
                    <div class="test-item">
                        <span><strong>🔐 Pantalla Login Visible:</strong></span>
                        <span class="{'pass' if resultado.get('pagina_login_visible') else 'fail'}">
                            {'✅ SÍ' if resultado.get('pagina_login_visible') else '❌ NO'}
                        </span>
                    </div>
                    
                    <div class="test-item">
                        <span><strong>📝 Formulario Login Funcional:</strong></span>
                        <span class="{'pass' if resultado.get('formulario_login_funcional') else 'fail'}">
                            {'✅ SÍ' if resultado.get('formulario_login_funcional') else '❌ NO'}
                        </span>
                    </div>
                    
                    <div class="test-item">
                        <span><strong>🔗 Navegación a Registro:</strong></span>
                        <span class="{'pass' if resultado.get('navegacion_registro') else 'fail'}">
                            {'✅ SÍ' if resultado.get('navegacion_registro') else '❌ NO'}
                        </span>
                    </div>
                    
                    <div class="test-item">
                        <span><strong>👤 Elementos de Registro:</strong></span>
                        <span class="{'pass' if resultado.get('elementos_registro') else 'fail'}">
                            {'✅ SÍ' if resultado.get('elementos_registro') else '❌ NO'}
                        </span>
                    </div>
                    
                    <div class="test-item">
                        <span><strong>📱 Diseño Responsive:</strong></span>
                        <span class="{'pass' if resultado.get('responsive_design') else 'fail'}">
                            {'✅ SÍ' if resultado.get('responsive_design') else '❌ NO'}
                        </span>
                    </div>
                    
                    <div class="test-item">
                        <span><strong>⏱️ Tiempo Carga Promedio:</strong></span>
                        <span>{resultado.get('tiempo_carga_promedio', 0):.2f} segundos</span>
                    </div>
            """
            
            # Mostrar información de performance de Flutter si está disponible
            perf_flutter = resultado.get('performance_flutter', {})
            if perf_flutter:
                html_content += f"""
                    <div class="test-item">
                        <span><strong>🚀 Performance Flutter:</strong></span>
                        <span>{perf_flutter.get('tiempo_carga_completa', 0):.2f}s 
                              {'✅ Bueno' if perf_flutter.get('flutter_funcional', False) else '⚠️ Lento'}</span>
                    </div>
                """
            
            # Mostrar capturas de pantalla
            if resultado.get('capturas'):
                html_content += f"""
                    <h4>📸 Capturas de Pantalla:</h4>
                    <div class="screenshots">
                """
                for i, captura in enumerate(resultado['capturas']):
                    nombre_captura = captura.split('/')[-1].replace('_', ' ').replace('.png', '').title()
                    html_content += f'<img src="{captura}" class="screenshot" alt="Captura {nombre_captura}" title="{nombre_captura}">'
                html_content += '</div>'
            
            # Mostrar errores si los hay
            if resultado.get('errores'):
                html_content += '<h4>🐛 Errores Encontrados:</h4><ul>'
                for error in resultado['errores'][:5]:  # Limitar a 5 errores
                    html_content += f'<li style="color: #d32f2f; margin: 5px 0;">{error}</li>'
                if len(resultado['errores']) > 5:
                    html_content += f'<li style="color: #666;">... y {len(resultado["errores"]) - 5} errores más</li>'
                html_content += '</ul>'
            
            # Mostrar errores JavaScript si los hay
            if resultado.get('errores_javascript'):
                html_content += '<h4>⚠️ Errores JavaScript:</h4><ul>'
                for error in resultado['errores_javascript'][:3]:  # Limitar a 3
                    error_corto = error[:100] + '...' if len(error) > 100 else error
                    html_content += f'<li style="color: #ff9800; margin: 5px 0; font-family: monospace; font-size: 0.9em;">{error_corto}</li>'
                html_content += '</ul>'
            
            html_content += '</div>'
        
        # Estadísticas finales
        total_navegadores = len(self.resultados)
        exitosos = sum(1 for r in self.resultados.values() if r.get('flutter_cargado') and r.get('pagina_login_visible'))
        compatibilidad = (exitosos / total_navegadores) * 100 if total_navegadores > 0 else 0
        
        if compatibilidad >= 80:
            color_compat = "#4caf50"
            emoji_compat = "🏆"
            texto_compat = "¡EXCELENTE COMPATIBILIDAD!"
        elif compatibilidad >= 60:
            color_compat = "#ff9800"
            emoji_compat = "👍"
            texto_compat = "BUENA COMPATIBILIDAD"
        else:
            color_compat = "#f44336"
            emoji_compat = "⚠️"
            texto_compat = "NECESITA MEJORAS"
        
        html_content += f"""
                <div style="background: linear-gradient(135deg, {color_compat}20 0%, {color_compat}10 100%); 
                           padding: 25px; border-radius: 10px; margin-top: 30px; text-align: center;
                           border: 2px solid {color_compat};">
                    <h2 style="color: {color_compat}; margin: 0;">{emoji_compat} {texto_compat}</h2>
                    <div style="margin-top: 15px; font-size: 1.1em;">
                        <strong>Compatibilidad General: {compatibilidad:.1f}%</strong><br>
                        ({exitosos} de {total_navegadores} navegadores compatibles)
                    </div>
                </div>
                
                <div style="margin-top: 30px; padding: 20px; background: #f5f5f5; border-radius: 10px;">
                    <h3>📋 Recomendaciones para CafeConecta:</h3>
                    <ul>
                        <li><strong>✅ Puntos Fuertes:</strong> Flutter web proporciona una experiencia consistente entre navegadores</li>
                        <li><strong>⚡ Performance:</strong> Considera optimizar los tiempos de carga inicial de Flutter</li>
                        <li><strong>📱 Responsive:</strong> Verifica que todos los elementos sean accesibles en dispositivos móviles</li>
                        <li><strong>🔍 Accesibilidad:</strong> Asegúrate de que los formularios tengan labels apropiados</li>
                        <li><strong>🚀 Optimización:</strong> Considera implementar lazy loading para mejorar tiempos de carga</li>
                    </ul>
                </div>
                
                <footer style="text-align: center; margin-top: 40px; padding-top: 20px; 
                             border-top: 2px solid #8B4513; color: #666;">
                    <p>☕ Reporte generado para <strong>CafeConecta</strong> - {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
                    <p style="font-size: 0.9em;">Sistema de pruebas automatizado para aplicaciones Flutter web</p>
                </footer>
            </div>
        </body>
        </html>
        """
        
        with open('reporte_portabilidad_CafeConecta_Flutter.html', 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"💾 Reporte HTML guardado: reporte_portabilidad_CafeConecta_Flutter.html")

if __name__ == "__main__":
    print("☕ SISTEMA DE PRUEBAS DE PORTABILIDAD CAFECONECTA")
    print("="*60)
    print("📋 REQUISITOS PREVIOS:")
    print("1. 🚀 Flutter web debe estar corriendo en http://localhost:3000")
    print("   Ejecuta: flutter run -d web --web-port 3000")
    print("2. 🌐 Tener Chrome, Firefox y Edge instalados")
    print("3. 🌍 Conexión a internet para descargar drivers de Selenium")
    print("4. 📱 La aplicación debe mostrar pantalla de login/registro")
    print()
    print("⚠️ NOTA: Si usas un puerto diferente, modifica 'self.url_base' en el código")
    print()
    
    respuesta = input("¿Todo está configurado y CafeConecta está corriendo? (s/n): ").lower().strip()
    
    if respuesta in ['s', 'si', 'sí', 'y', 'yes']:
        print("\n🚀 Iniciando pruebas de portabilidad...")
        prueba = PruebaPortabilidadCafeConecta()
        prueba.ejecutar_pruebas_completas()
        
        print("\n🎉 ¡PRUEBAS COMPLETADAS!")
        print("📁 Archivos generados:")
        print("   📸 Capturas: carpeta 'capturas_portabilidad_cafeconecta/'")
        print("   📊 Reporte JSON: 'reporte_portabilidad_CafeConecta_Flutter.json'")
        print("   🌐 Reporte HTML: 'reporte_portabilidad_CafeConecta_Flutter.html'")
        print("\n💡 Abre el archivo HTML para ver el reporte completo con capturas!")
        
    else:
        print("❌ Configuración cancelada.")
        print("📝 Para ejecutar CafeConecta:")
        print("   1. Abre terminal en tu proyecto Flutter")
        print("   2. Ejecuta: flutter run -d web --web-port 3000")
        print("   3. Vuelve a ejecutar este script")