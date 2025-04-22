# Multiplicador IEEE‑754 (fp_multiplier)

### Descripción  
Este proyecto implementa un **multiplicador de números en formato IEEE‑754 de precisión simple (32 bits)** en VHDL. Cada operando de entrada (`A`, `B`) se descompone en:

- **Signo** (1 bit)  
- **Exponente** (8 bits, con sesgo de 127)  
- **Mantisa** (23 bits, más un “1” implícito)  

A partir de ahí:
1. Se reconstruye el significando completo de 24 bits (`1.f`).  
2. Se multiplican ambas mantisas (48 bits de producto).  
3. Se normaliza el resultado (ajuste de mantisa y exponente).  
4. Se empaqueta de nuevo en 32 bits (signo–exponente–mantisa).

### Contexto
Este proyecto fue desarrollado como parte del curso Circuitos Lógicos Programables, perteniente a la Especialización en Sistemas Embebidos de FIUBA.

**Profesor**: Nicolás Álvarez