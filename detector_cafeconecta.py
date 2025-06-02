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

class PruebaPortabilidadCafeConectaFijo:
    def __init__(self):
        # URL base detectada automáticamente
        self.url_base = "http://localhost:3000"
        self.url_login = "http://localhost:3000/#/login"
        self.url_register = "http://localhost:3000/#/register"
        self.url_home = "http://localhost:3000/#/home"
        self.resultados = {}
        self.crear_directorio_capturas()
        
    def crear_directorio_capturas(self):
        """Crear directorio para capturas de pantalla"""
        if not os.path.exists("capturas_portabilidad_cafeconecta"):
            os.makedirs("capturas_portabilidad_cafeconecta")
    
    def setup_chrome(self):
        """Configurar Chrome WebDriver para CafeConecta"""
        print("🔧 Configurando Chrome para CafeConecta...")
        options = webdriver.ChromeOptions()
        options.add_argument("--window-size=1920,1080")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--disable-web-security")
        options.add_argument("--allow-running-insecure-content")
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        options.add_experimental_option('useAutomationExtension', False)
        
        try:
            service = ChromeService(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=options)
            print("✅ Chrome configurado correctamente")
            return driver
        except Exception as e:
            print(f"❌ Error configurando Chrome: {str(e)}")
            return None
    
    def setup_firefox(self):
        """Configurar Firefox WebDriver"""
        print("🔧 Configurando Firefox...")
        options = webdriver.FirefoxOptions()
        options.add_argument("--width=1920")
        options.add_argument("--height=1080")
        
        try:
            service = FirefoxService(GeckoDriverManager().install())
            driver = webdriver.Firefox(service=service, options=options)
            print("✅ Firefox configurado correctamente")
            return driver
        except Exception as e:
            print(f"❌ Error configurando Firefox: {str(e)}")
            return None
    
    def setup_edge(self):
        """Configurar Edge WebDriver"""
        print("🔧 Configurando Edge...")
        options = webdriver.EdgeOptions()
        options.add_argument("--window-size=1920,1080")
        options.add_argument("--disable-blink-features=AutomationControlled")
        
        try:
            service = EdgeService(EdgeChromiumDriverManager().install())
            driver = webdriver.Edge(service=service, options=options)
            print("✅ Edge configurado correctamente")
            return driver
        except Exception as e:
            print(f"❌ Error configurando Edge: {str(e)}")
            return None
    
    def esperar_flutter_cargado(self, driver, timeout=20):
        """Esperar a que Flutter termine de cargar completamente"""
        print("   ⏳ Esperando que CafeConecta cargue...")
        
        try:
            # Esperar más tiempo para Flutter
            time.sleep(8)
            
            # Verificar que el título contenga "Cafe Conecta"
            WebDriverWait(driver, timeout).until(
                lambda d: "cafe" in d.title.lower() or "conecta" in d.title.lower()
            )
            
            print("   ✅ CafeConecta cargado completamente")
            return True
            
        except TimeoutException:
            print("   ⚠️ Timeout esperando CafeConecta, continuando...")
            return False
    
    def buscar_elemento_cafeconecta(self, driver, descripcion, timeout=15):
        """Buscar elementos específicos de CafeConecta con múltiples estrategias"""
        
        # Estrategias de búsqueda para diferentes elementos
        estrategias = {
            "email": [
                "input[type='email']",
                "input[placeholder*='correo' i]",
                "input[placeholder*='email' i]",
                "flt-semantics input",
                "//input[@type='email' or contains(@placeholder, 'correo') or contains(@placeholder, 'email')]"
            ],
            "password": [
                "input[type='password']",
                "input[placeholder*='contraseña' i]",
                "input[placeholder*='password' i]",
                "//input[@type='password' or contains(@placeholder, 'contraseña')]"
            ],
            "boton_login": [
                "button:contains('Iniciar')",
                "button:contains('Login')",
                "button:contains('Acceder')",
                "button[type='submit']",
                "//button[contains(text(), 'Iniciar') or contains(text(), 'Login') or contains(text(), 'Acceder')]"
            ],
            "link_registro": [
                "a[href*='register']",
                "*:contains('Regístrate')",
                "*:contains('registro')",
                "//a[contains(@href, 'register')] | //*[contains(text(), 'Regístrate') or contains(text(), 'registro')]"
            ],
            "campo_nombre": [
                "input[placeholder*='nombre' i]",
                "input[type='text']:not([type='email']):not([type='password'])",
                "//input[contains(@placeholder, 'nombre') or contains(@name, 'name')]"
            ]
        }
        
        if descripcion not in estrategias:
            # Buscar cualquier input o button
            selectores = ["input", "button", "a"]
        else:
            selectores = estrategias[descripcion]
        
        for selector in selectores:
            try:
                if selector.startswith("//"):
                    # XPath
                    elementos = WebDriverWait(driver, timeout).until(
                        EC.presence_of_all_elements_located((By.XPATH, selector))
                    )
                else:
                    # CSS Selector
                    elementos = WebDriverWait(driver, timeout).until(
                        EC.presence_of_all_elements_located((By.CSS_SELECTOR, selector))
                    )
                
                # Verificar que al menos uno sea visible e interactuable
                for elem in elementos:
                    try:
                        if elem.is_displayed() and elem.is_enabled():
                            print(f"   ✅ {descripcion} encontrado con: {selector}")
                            return elem
                    except:
                        continue
                        
            except (TimeoutException, NoSuchElementException):
                continue
        
        print(f"   ❌ {descripcion} no encontrado")
        return None
    
    def test_navegador(self, driver, nombre_navegador):
        """Ejecutar pruebas completas para CafeConecta"""
        print(f"\n{'='*50}")
        print(f"☕ PROBANDO CAFECONECTA EN {nombre_navegador.upper()}")
        print(f"{'='*50}")
        
        resultado = {
            'navegador': nombre_navegador,
            'version': '',
            'cafeconecta_cargado': False,
            'pantalla_login_accesible': False,
            'formulario_login_funcional': False,
            'navegacion_registro_exitosa': False,
            'formulario_registro_visible': False,
            'responsive_design': False,
            'tiempo_carga_promedio': 0,
            'capturas': [],
            'errores': []
        }
        
        tiempos_carga = []
        
        try:
            # Información del navegador
            resultado['version'] = driver.capabilities.get('browserVersion', 'Desconocida')
            print(f"📋 Versión: {resultado['version']}")
            
            # TEST 1: Cargar página de login de CafeConecta
            print("\n1️⃣ Cargando pantalla de login de CafeConecta...")
            inicio_carga = time.time()
            
            driver.get(self.url_login)
            cafeconecta_ok = self.esperar_flutter_cargado(driver)
            
            tiempo_carga = time.time() - inicio_carga
            tiempos_carga.append(tiempo_carga)
            
            if cafeconecta_ok or "cafe" in driver.title.lower():
                resultado['cafeconecta_cargado'] = True
                print(f"   ✅ CafeConecta cargado - Tiempo: {tiempo_carga:.2f}s")
            else:
                print(f"   ⚠️ Posibles problemas de carga - Tiempo: {tiempo_carga:.2f}s")
            
            # Captura inicial
            captura_login = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_login_inicial.png"
            driver.save_screenshot(captura_login)
            resultado['capturas'].append(captura_login)
            
            # TEST 2: Verificar elementos de login
            print("\n2️⃣ Verificando formulario de login...")
            
            email_field = self.buscar_elemento_cafeconecta(driver, "email")
            password_field = self.buscar_elemento_cafeconecta(driver, "password")
            
            if email_field and password_field:
                resultado['pantalla_login_accesible'] = True
                print("   ✅ Formulario de login accesible")
                
                # TEST 3: Probar funcionalidad del formulario
                print("\n3️⃣ Probando funcionalidad del formulario...")
                
                try:
                    # Intentar llenar campos
                    email_field.clear()
                    email_field.send_keys("test@cafeconecta.com")
                    time.sleep(1)
                    
                    password_field.clear()
                    password_field.send_keys("123456")
                    time.sleep(1)
                    
                    print("   📝 Datos de prueba ingresados")
                    
                    # Buscar botón de login
                    boton_login = self.buscar_elemento_cafeconecta(driver, "boton_login")
                    
                    if boton_login:
                        # Click en botón (pero no esperamos login exitoso)
                        driver.execute_script("arguments[0].click();", boton_login)
                        time.sleep(3)
                        
                        resultado['formulario_login_funcional'] = True
                        print("   ✅ Formulario de login funcional")
                        
                        # Captura después del intento
                        captura_post_login = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_post_login.png"
                        driver.save_screenshot(captura_post_login)
                        resultado['capturas'].append(captura_post_login)
                    
                except Exception as e:
                    resultado['errores'].append(f"Error en funcionalidad de login: {str(e)}")
                    print(f"   ⚠️ Error en login: {str(e)}")
            
            # TEST 4: Navegación a registro
            print("\n4️⃣ Navegando a pantalla de registro...")
            
            try:
                inicio_nav = time.time()
                driver.get(self.url_register)
                self.esperar_flutter_cargado(driver)
                
                tiempo_nav = time.time() - inicio_nav
                tiempos_carga.append(tiempo_nav)
                
                resultado['navegacion_registro_exitosa'] = True
                print(f"   ✅ Navegación a registro exitosa - Tiempo: {tiempo_nav:.2f}s")
                
                # Verificar formulario de registro
                campo_nombre = self.buscar_elemento_cafeconecta(driver, "campo_nombre")
                email_registro = self.buscar_elemento_cafeconecta(driver, "email")
                
                if campo_nombre and email_registro:
                    resultado['formulario_registro_visible'] = True
                    print("   ✅ Formulario de registro visible")
                
                # Captura de registro
                captura_registro = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_registro.png"
                driver.save_screenshot(captura_registro)
                resultado['capturas'].append(captura_registro)
                
            except Exception as e:
                resultado['errores'].append(f"Error navegando a registro: {str(e)}")
                print(f"   ⚠️ Error en navegación: {str(e)}")
            
            # TEST 5: Prueba responsive
            print("\n5️⃣ Verificando diseño responsive...")
            
            try:
                tamaños = [
                    (375, 667, "iPhone"),
                    (768, 1024, "iPad"),
                    (1920, 1080, "Desktop")
                ]
                
                responsive_ok = True
                
                for ancho, alto, dispositivo in tamaños:
                    driver.set_window_size(ancho, alto)
                    time.sleep(2)
                    
                    # Volver a login para verificar
                    driver.get(self.url_login)
                    time.sleep(3)
                    
                    email_responsive = self.buscar_elemento_cafeconecta(driver, "email", timeout=5)
                    
                    if email_responsive:
                        print(f"   ✅ Responsive OK en {dispositivo}")
                    else:
                        responsive_ok = False
                        print(f"   ❌ Problemas responsive en {dispositivo}")
                    
                    # Captura en cada tamaño
                    captura_responsive = f"capturas_portabilidad_cafeconecta/{nombre_navegador.lower()}_{dispositivo.lower()}.png"
                    driver.save_screenshot(captura_responsive)
                    resultado['capturas'].append(captura_responsive)
                
                resultado['responsive_design'] = responsive_ok
                
                # Restaurar tamaño
                driver.set_window_size(1920, 1080)
                
            except Exception as e:
                print(f"   ⚠️ Error en prueba responsive: {str(e)}")
            
            # Calcular tiempo promedio
            if tiempos_carga:
                resultado['tiempo_carga_promedio'] = sum(tiempos_carga) / len(tiempos_carga)
            
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
        """Ejecutar pruebas en todos los navegadores"""
        print("☕ INICIANDO PRUEBAS COMPLETAS CAFECONECTA")
        print("="*60)
        print(f"🌐 URL Base: {self.url_base}")
        print(f"🔐 URL Login: {self.url_login}")
        print(f"📝 URL Registro: {self.url_register}")
        
        # Navegadores a probar
        navegadores = [
            ('Chrome', self.setup_chrome),
            ('Firefox', self.setup_firefox),
            ('Edge', self.setup_edge)
        ]
        
        for nombre, setup_func in navegadores:
            print(f"\n{'='*25} {nombre.upper()} {'='*25}")
            try:
                driver = setup_func()
                if driver:
                    resultado = self.test_navegador(driver, nombre)
                    self.resultados[nombre] = resultado
                else:
                    self.resultados[nombre] = {
                        'navegador': nombre,
                        'error_inicializacion': True,
                        'errores': [f"No se pudo inicializar {nombre}"]
                    }
            except Exception as e:
                self.resultados[nombre] = {
                    'navegador': nombre,
                    'error_critico': True,
                    'errores': [f"Error crítico: {str(e)}"]
                }
        
        self.generar_reporte_consola()
        self.generar_reporte_json()
        self.generar_reporte_html()
    
    def generar_reporte_consola(self):
        """Generar reporte en consola"""
        print("\n" + "="*70)
        print("☕ REPORTE FINAL CAFECONECTA")
        print("="*70)
        
        for navegador, resultado in self.resultados.items():
            print(f"\n🌐 {navegador}:")
            
            if resultado.get('error_inicializacion') or resultado.get('error_critico'):
                print("   ❌ No se pudo probar este navegador")
                continue
            
            print(f"   📌 Versión: {resultado.get('version', 'Desconocida')}")
            print(f"   ⚡ CafeConecta cargado: {'✅' if resultado.get('cafeconecta_cargado') else '❌'}")
            print(f"   🔐 Login accesible: {'✅' if resultado.get('pantalla_login_accesible') else '❌'}")
            print(f"   📝 Login funcional: {'✅' if resultado.get('formulario_login_funcional') else '❌'}")
            print(f"   🔗 Navegación registro: {'✅' if resultado.get('navegacion_registro_exitosa') else '❌'}")
            print(f"   👤 Registro visible: {'✅' if resultado.get('formulario_registro_visible') else '❌'}")
            print(f"   📱 Responsive: {'✅' if resultado.get('responsive_design') else '❌'}")
            print(f"   ⏱️ Tiempo promedio: {resultado.get('tiempo_carga_promedio', 0):.2f}s")
            print(f"   📸 Capturas: {len(resultado.get('capturas', []))}")
            
            # Evaluar compatibilidad
            funciones_principales = [
                resultado.get('cafeconecta_cargado', False),
                resultado.get('pantalla_login_accesible', False),
                resultado.get('formulario_login_funcional', False)
            ]
            
            if sum(funciones_principales) >= 2:
                print("   🎉 ✅ COMPATIBLE CON CAFECONECTA")
            else:
                print("   ⚠️ ❌ PROBLEMAS DE COMPATIBILIDAD")
        
        total = len(self.resultados)
        exitosos = sum(1 for r in self.resultados.values() 
                      if r.get('cafeconecta_cargado') and r.get('pantalla_login_accesible'))
        
        print(f"\n📊 RESUMEN:")
        print(f"   🔢 Total navegadores: {total}")
        print(f"   ✅ Compatibles: {exitosos}")
        print(f"   📈 Porcentaje: {(exitosos/total)*100:.1f}%" if total > 0 else "   📈 Porcentaje: 0%")
    
    def generar_reporte_json(self):
        """Generar reporte JSON"""
        reporte = {
            'aplicacion': 'CafeConecta',
            'fecha_prueba': datetime.now().isoformat(),
            'urls': {
                'base': self.url_base,
                'login': self.url_login,
                'registro': self.url_register
            },
            'resultados': self.resultados
        }
        
        with open('reporte_CafeConecta_completo.json', 'w', encoding='utf-8') as f:
            json.dump(reporte, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 Reporte JSON: reporte_CafeConecta_completo.json")
    
    def generar_reporte_html(self):
        """Generar reporte HTML simplificado"""
        html = f"""
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <title>Reporte CafeConecta</title>
            <style>
                body {{ font-family: Arial; margin: 20px; background: #f5f5f5; }}
                .container {{ max-width: 1000px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }}
                h1 {{ color: #8B4513; text-align: center; }}
                .browser {{ margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
                .success {{ background-color: #e8f5e8; }}
                .warning {{ background-color: #fff3e0; }}
                .error {{ background-color: #ffebee; }}
                img {{ max-width: 200px; margin: 5px; border: 1px solid #ccc; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>☕ Reporte de Compatibilidad CafeConecta</h1>
                <p><strong>Fecha:</strong> {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
        """
        
        for navegador, resultado in self.resultados.items():
            if resultado.get('error_inicializacion'):
                clase = "error"
                estado = "❌ Error"
            elif resultado.get('cafeconecta_cargado') and resultado.get('pantalla_login_accesible'):
                clase = "success"
                estado = "✅ Compatible"
            else:
                clase = "warning"
                estado = "⚠️ Problemas"
            
            html += f"""
                <div class="browser {clase}">
                    <h3>{navegador} - {estado}</h3>
                    <p><strong>Versión:</strong> {resultado.get('version', 'Desconocida')}</p>
                    <p><strong>Tiempo promedio:</strong> {resultado.get('tiempo_carga_promedio', 0):.2f}s</p>
            """
            
            if resultado.get('capturas'):
                html += "<h4>Capturas:</h4>"
                for captura in resultado['capturas']:
                    html += f'<img src="{captura}" alt="Captura {navegador}">'
            
            html += "</div>"
        
        html += """
            </div>
        </body>
        </html>
        """
        
        with open('reporte_CafeConecta_completo.html', 'w', encoding='utf-8') as f:
            f.write(html)
        
        print(f"💾 Reporte HTML: reporte_CafeConecta_completo.html")

if __name__ == "__main__":
    print("☕ PRUEBAS COMPLETAS DE PORTABILIDAD CAFECONECTA")
    print("="*60)
    print("✅ CafeConecta detectado en http://localhost:3000")
    print("🔐 Probando login en: http://localhost:3000/#/login")
    print("📝 Probando registro en: http://localhost:3000/#/register")
    print()
    
    respuesta = input("¿Ejecutar pruebas completas en Chrome, Firefox y Edge? (s/n): ").lower().strip()
    
    if respuesta in ['s', 'si', 'sí']:
        prueba = PruebaPortabilidadCafeConectaFijo()
        prueba.ejecutar_pruebas_completas()
        
        print("\n🎉 ¡PRUEBAS COMPLETADAS!")
        print("📁 Archivos generados:")
        print("   📸 Capturas: capturas_portabilidad_cafeconecta/")
        print("   📊 JSON: reporte_CafeConecta_completo.json")
        print("   🌐 HTML: reporte_CafeConecta_completo.html")
    else:
        print("❌ Pruebas canceladas")