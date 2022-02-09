.data

	slist: .word 0
	cclist: .word 0
	wclist: .word 0
	buffer: .space 16
	
	
	# Mensajes menu
	
	pregunta: .asciiz "\nQue desea hacer?\n"
	seleccionada: .asciiz "\nCategoria seleccionada: \n"
	eleccion: .asciiz "1: Crear nueva categoria\n2: Seleccionar otra categoria.\n3: Listar categorias\n4: Borrar categoria\n5: Anexar objeto\n6: Borrar objeto\n7: Listar objetos\n0: salir\n"
	
	
	# Mensajes de seleccionar_categorias
	
	mover_lista: .asciiz "\n1: Mover a la izquierda.\n2: Mover a la derecha.\n3: Elegir esta categoria.\n"

	
	# Mensaje print_string
	
	ingreseString: .asciiz "\nIngrese un nuevo titulo: "
	
	# Mensaje listar
	
	msj_listar: .asciiz "\nEstos son los elementos de la lista:\n\n"
	asterisco: .asciiz "*"
	
	# Mensaje borrar objeto
	
	msj_borrar_obj: .asciiz "\nIngrese el ID del objeto a eliminar: "

	
.text

main:
		li		$s0, 0
		li		$s1, 0
		li		$s2, 0
		
		j menu


smalloc: 



		li 		$v0, 0				# $v0 = 0
		lw		$t1, slist			# $t1 = *lista
		beqz	$t1, sbrk			# if *lista == 0, asignar 16 bytes a newnode
									# else:
									
		move	$v0, $t1			# return *lista 
		
		lw 		$t1, 12($t1)		# slist = slist->next
		sw		$t1, slist			# 
		jr 		$ra


sbrk:
		li		$a0, 16				# 16 bytes 
		li 		$v0, 9
		syscall						# se guarda en $v0 una dirección con 16 bytes de memoria
		jr		$ra


sfree:
		la		$t0, slist			# $t0 = puntero anterior al que apuntaba slist
		sw 		$t0, 12($a0)		# siguiente nodo en la lista apunta a la direccion anterior de slist
		sw		$a0, slist			# slist apunta a nuevo bloque de memoria
		jr		$ra



	# ADDNODE: Esta funcion toma un nuevo nodo como argumento, y lo asigna a la lista.

	#if(head == 0){					;head = $s0
    #        head = newNode;		newNode = $v0
    #        tail = newNode;		tail = $s1
    #        head->next = head;		head->next = 12($s0)
    #        head->prev = head;		head->prev = 0($s0)
    #         selector = head;		selector = $s2
	#
    #    } else {
    #        tail->next = newNode;	tail->next = 12($s1)
    #        newNode->prev = tail;	newNode->prev = 0($v0)
    #        newNode->next = head;	newNode->next = 12($v0)
    #        head->prev = newNode;	head->prev = 0($s0)
    #        tail = newNode;		
    #    }
	
	#VARS: 
	#$s0= HEAD
	#$s1= TAIL
	#$s2= SELECTOR
	#$v0= NEWNODE
		
		
addnode: 
		addi 		$sp, $sp, -8
		sw 			$ra, 4($sp)
		sw			$s0, 0($sp)


		move 		$s0, $a0			# lista utilizada
		jal			smalloc				# newnode($v0)=(node*)malloc(sizeof(node))
		lw			$t0, 0($s0)			# dir a primer nodo
		beqz		$t0, first			# si la lista está vacía
		
		lw			$t1, 0($t0)			# $t1 = ULTIMO
		
		sw			$v0, 12($t1)		# tail->next = newNode
		sw			$t1, 0($v0)			# newNode->prev = tail
		sw			$t0, 12($v0)		# newNode->next = head
		sw			$v0, 0($t0)			# head->prev = newNode
		
		j 			_addnode

first:
		
		sw			$v0, 12($v0)		# nuevo->next = nuevo
		sw			$v0, 0($v0)			# nuevo->prev = nuevo
		sw			$v0, 0($s0)			# head = nuevo
			
_addnode:
		
		lw			$s0, 0($sp)
		lw			$ra, 4($sp)
		addi		$sp, $sp, 8
		j			$ra
			
	
	
	
	
	
	
	# CREAR_CATEGORIA:
	# Esta funcion toma un string del usuario, y lo usa para crear el nodo que va a ser añadido con la funcion addnode
	#
	
crear_categoria:

		addi 		$sp, $sp, -8
		sw 			$ra, 4($sp)
		sw			$s0, 0($sp)
		
		
		
		jal 		read_string
		
		la			$a0, cclist
		jal			addnode
		
		move		$s0, $v0		# $s0 = newnode
		sw			$0, 8($s0)		# nuevo->objetos = NULL
		
		jal 		smalloc	
		sw			$v0, 4($s0)		# asignar espacio a nuevo->nombre
		
		
		la			$a0, buffer
		move		$a1, $v0
		jal			copy_str		# copiar string bit por bit
		
		la $t0, buffer
		add $t0, $t0, $v0	
		lb $t0, 0($t0)		
		
		
		lw			$t0, wclist
		bnez		$t0, _crear_categoria
		sw			$s0, wclist
		

_crear_categoria:
		
		lw			$s0, 0($sp)
		lw 			$ra, 4($sp)
		addi 		$sp, $sp, 8
		


		j			$ra
	
	
	
	# SELECCIONAR_CATEGORIAS
	# Esta funcion recibe un input del usuario, en el que este decide si
	# se quiere mover a la "derecha" o "izquierda" dentro de la lista de categorias
	# cambiando así la lista seleccionada a la escogida
	
seleccionar_categorias:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		lw			$t0, wclist
		beqz		$t0, _seleccionar_categorias 		# si no hay listas, volver al menu

		la			$a0, seleccionada
		jal 		print_string
		
		lw			$t0, wclist			# carga la lista seleccionada en $t0
		lw			$a0, 4($t0)			# mostrar el contenido de la misma
		jal			print_string
		
		
		la			$a0, mover_lista
		jal			print_string
		
		jal 		read_word			# leer decision
		
		move		$t0, $v0
		beq			$t0, 1, mover_izq
		beq			$t0, 2, mover_der
		beq			$t0, 3, _seleccionar_categorias
		

		
		
mover_izq:		# list_selec = list_selec->prev
		
		lw			$t0, wclist
		lw			$t1, 0($t0)
		sw			$t1, wclist
		
		j			seleccionar_categorias		# volver al inicio de la funcion

mover_der:		# list_selec = list_selec->next

		lw			$t0, wclist
		lw			$t1, 12($t0)
		sw			$t1, wclist
		
		j			seleccionar_categorias		# volver al inicio de la funcion


_seleccionar_categorias:	# fin de funcion

		lw 			$ra, 0($sp)
		addi 		$sp, $sp, 4
		
		j			$ra


	# LISTAR_CAT
	# Esta funcion recorre toda la lista ingresada, imprimiendo en pantalla cada uno de sus
	# valores, incluyendo un asterisco delante de la lista seleccionada

listar_cat:

		addi 		$sp, $sp, -8
		sw 			$ra, 4($sp)
		sw			$s0, 0($sp)
		
		lw			$t0, wclist
		lw			$s0, cclist			# $s0 es *lista
		
		beqz		$s0, _listar_cat	# Si la lista es vacia, volver
			
		move		$t1, $s0			# $t1 es nodo index
		move		$t2, $s0			# $t2 es la dir al primer nodo
		
		la			$a0, msj_listar
		jal 		print_string
		
loop_listar_cat:
	
		
		
		# SI la lista que se está recorriendo es la seleccionada, ir a if_listar_cat
		beq			$t1, $t0, if_listar_cat
		
		_if_listar_cat:
		
		lw			$a0, 4($t1)			# Pasar como argumento el string de la categoria
		jal			print_string
		
		lw			$t1, 12($t1)		# index = index->next
		
		beq			$t1, $t2, _listar_cat	#si el index es igual al head, terminar de mostrar
		
		j loop_listar_cat
		
		
if_listar_cat:
		# Imprimir un asterisco delante de la lista seleccionada
		la			$a0, asterisco
		jal print_string
		j _if_listar_cat
		

_listar_cat:
		
		lw			$s0, 0($sp)
		lw 			$ra, 4($sp)
		addi 		$sp, $sp, 8
		
		j			$ra
		
		
		
		
	# BORRAR_CAT
	
borrar_cat:
		
		addi 		$sp, $sp, -8
		sw 			$ra, 4($sp)
		sw			$s0, 0($sp)
		
		lw			$s0, wclist			# Guardar nodo seleccionado en $s0
		lw			$s1, cclist			# Guardar lista en $s1
		
		beqz		$s0, _borrar_cat	# si es vacia, volver
		
		lw			$t0, 0($s0)			# Guardar en $t0 la dir al nodo anterior
		lw			$t1, 12($s0)		# Guardar en $t1 la dir al nodo siguiente
		sw			$t0, 0($t1)			# $t1->ant = $t0
		sw			$t1, 12($t0)		# $t0->sig = $t1
		move		$s2, $t0			# Guardar valor de nodo->ant en s2
		move		$s3, $t1			# Guardar valor de nodo->sig en s3
		
		lw			$a0, 4($s0)
		jal			sfree				# liberar espacio del string 
		move		$a0, $s0			
		jal			sfree				# liberar espacio del nodo
		
		bne			$s0, $s1, borrar_noprim		# si no es el primero de la lista, ir a borrar_noprim
		bne			$s2, $s3, borrar_prim		# si no es el unico elemento de la lista, ir a borrar_prim
		
		
		sw			$0, wclist
		sw			$0, cclist
		
		j 			_borrar_cat
		
		
borrar_prim:
		sw			$t1, cclist
		j 			_borrar_cat
		
borrar_noprim:
		
		sw			$t1, wclist
	
	
_borrar_cat:

		lw			$s0, 0($sp)
		lw 			$ra, 4($sp)
		addi 		$sp, $sp, 8
		
		j			$ra
		
		
	
	
	
	
	
	# AGREGAR_OBJ
	
agregar_obj:

		addi 		$sp, $sp, -8
		sw 			$ra, 4($sp)
		sw			$s0, 0($sp)
		
		lw			$t0, wclist		# $t0 = selec
		
		beqz		$t0, _agregar_obj	# si no hay nodo seleccionado, volver al menu
		
		la			$s0, 8($t0)		# $s0 = selec->objetos
		
		
		
		
		jal 		read_string		# leer nombre de objeto
		
		move		$a0, $s0		
		jal 		addnode			# añadir nodo a lista de objetos en categoria
		
		move		$s1, $v0		# $s1 = newnode
		
		
		jal 		smalloc	
		sw			$v0, 4($s1)		# asignar espacio a nuevo->nombre
		
		
		la			$a0, buffer		
		move		$a1, $v0
		jal			copy_str		# copiar string bit por bit
		
		
		
		beqz		$s0, l_vacia	# si la lista es vacia, ir a l_vacia
		
		lw			$t0, 0($s1)		# $t0 = nuevo->anterior
		lw			$t0, 8($t0)		# $t0 = nuevo->anterior->id
		addi		$t0, $t0, 1		# $t0 += 1
		
		sw			$t0, 8($s1)		# nuevo->id = $t0
		
		j			_agregar_obj
		
l_vacia:							# el ID del primer objeto es 1
		li			$t0, 1
		sw			$t0, 8($s1)
		
_agregar_obj:

		lw			$s0, 0($sp)
		lw 			$ra, 4($sp)
		addi 		$sp, $sp, 8
		
		j			$ra
		
		
		
	# BORRAR_OBJ
	# Borrar objeto pide al usuario el ID del objeto a borrar
	# luego toma la lista seleccionada y la recorre hasta encontrar dicho objeto
	# entonces borra la memoria del mismo
		
borrar_obj:

		addi 		$sp, $sp, -8
		sw 			$ra, 4($sp)
		sw			$s0, 0($sp)
		
		lw			$s2 wclist			# $s2 = nodo seleccionado
		
		beqz		$s2, _borrar_obj	# si el nodo seleccionado es vacio, volver al menu
		
		lw			$s0, 8($s2)			# $s0 = dir al primer nodo
		
		beqz		$s0, _borrar_obj	# si hay nodo seleccionado, pero su lista de objetos es vacia, volver al menu
		
		move		$t0, $s0			# $t0 = nodo index
		
		beqz		$s0, _borrar_obj	# Si la lista es vacia, volver
		
		la			$a0, msj_borrar_obj
		jal			print_string

		jal			read_word
		move		$t1, $v0
		
loop_borrar_obj:

		lw			$t2, 8($t0)
		beq			$t1, $t2, _loop_borrar_obj
		
		lw			$t0, 12($t0)
		
		beq			$t0, $s0, _borrar_obj

		j loop_borrar_obj

_loop_borrar_obj:
		
		move		$s1, $t0			# Guardar nodo a borrar en $s1
		lw			$t0, 0($s1)			# Guardar en $t0 la dir al nodo anterior
		lw			$t1, 12($s1)		# Guardar en $t1 la dir al nodo siguiente
		sw			$t0, 0($t1)			# $t1->ant = $t0
		sw			$t1, 12($t0)		# $t0->sig = $t1
		
		move		$s3, $t0			# Guardar nodo->ant en $s3
		move		$s4, $t1			# Guardar nodo->sig en $s4
		
		lw			$a0, 4($s1)
		jal			sfree				# liberar espacio del string 
		la			$a0, 8($s1)			
		jal			sfree				# liberar espacio de ID

		move		$a0, $s1			
		jal			sfree				# liberar espacio del nodo
		
		
		
		bne			$s0, $s1, _borrar_obj		# si no es el primero de la lista, ir al final
		bne			$s3, $s4, borrar_prim_obj		# si no es el unico elemento de la lista, ir a borrar_prim_obj
	
		
		sw			$0, 8($s2)					# 
		sw			$s2, wclist					# nodo_seleccionado->objetos = NULL
		
		j 			_borrar_cat
		
		
borrar_prim_obj:
		sw			$t1, 8($t0)					# Si es el primero, ahora el siguiente es el primero

_borrar_obj:

		lw			$s0, 0($sp)
		lw 			$ra, 4($sp)
		addi 		$sp, $sp, 8
		
		j			$ra

		
		
		
	
listar_obj:

		addi 		$sp, $sp, -8
		sw 			$ra, 4($sp)
		sw			$s0, 0($sp)
		
		
		lw			$t0, wclist		# $t0 = nodo seleccionado
		
		beqz		$t0, _listar_obj	# si no hay nodo seleccionado, volver al menu
		
		lw			$s0, 8($t0)		# $s0 = dir al primer nodo
		
		beqz		$s0, _listar_obj	# si hay nodo seleccionado pero sin lista de objetos, volver al menu
		
		move		$t0, $s0		# $t0 = nodo index
		
		la			$a0, msj_listar
		jal			print_string
		
		beqz		$s0, _listar_obj # Si la lista es vacia, volver
		

		
listar_obj_loop:
		
		lw			$a0, 8($t0)
		jal			print_int
		
		li			$a0, '.'
		jal			print_char
		
		lw			$a0, 4($t0)
		jal			print_string
		
		lw			$t0, 12($t0)
		
		beq			$t0, $s0, _listar_obj
		
		j 			listar_obj_loop
		
		
_listar_obj:
		
		lw			$s0, 0($sp)
		lw 			$ra, 4($sp)
		addi 		$sp, $sp, 8
		
		j			$ra
	


	# MENU
	# Menu de la aplicacion, donde se decide que operacion realizar
	
menu:
	# Imprimir el menu en pantalla
	
		la 			$a0, pregunta
		jal 		print_string
		la			$a0, seleccionada
		jal 		print_string
		lw			$t0, wclist			# carga la lista seleccionada en $t0
		beqz		$t0, sin_cat		# si es la primera iteracion, no hay lista seleccionada
		lw			$a0, 4($t0)			# sino, muestra el nombre de la lista
		jal			print_string
sin_cat:
		
		la 			$a0, eleccion
		jal 		print_string
		

		# leer opcion elegida
		jal 		read_word
		
		move 		$a0, $v0
		jal opciones_elegidas
	
		
		j 			menu

	

	# OPCIONES_ELEGIDAS
	# Dependiendo de la decision tomada en el menu, se salta
	# hacia la funcion adecuada para tal operacion
	# args:
	# $a0: numero de decision
	
opciones_elegidas:
		addi $sp, $sp, -4
		sw $ra, 0($sp)	
	# a0 = opcion
		move 		$t0, $a0
		
		beq			$t0, 0, end
		beq			$t0, 1, crear_categoria
		beq			$t0, 2, seleccionar_categorias
		beq			$t0, 3, listar_cat
		beq			$t0, 4, borrar_cat
		beq			$t0, 5, agregar_obj
		beq			$t0, 6, borrar_obj
		beq			$t0, 7, listar_obj
		
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		
		j $ra

		
		
		
		
		
		
	# PRINT_STRING
	# print_string imprime una cadena en la consola
	# $a0 = string
print_string:
		
		li      	$v0, 4
		syscall
		jr     	 	$ra


	# PRINT_INT
	# imprimir entero
	# $a0 = int
print_int:
		li			$v0, 1
		syscall
		jr			$ra


	# PRINT_char
	# imprimir byte
	# $a0 = byte
print_char:
		li			$v0, 11
		syscall
		jr			$ra

	# READ_WORD
	# lee un input numerico del usuario
read_word:
		li 			$v0, 5
		syscall
		
		j 			$ra
	

	# READ_STRING
	# read_string: lee una cadena ingresada por el usuario
	# $a0 = tamaño
read_string:


		la			$a0, ingreseString
		li			$v0, 4
		syscall
		
		li			$v0, 8
		la			$a0, buffer
		li			$a1, 18
		syscall
		
		
		j			$ra





		.text
copy_str:
		and 		$v0, $0, $0			# $v0 = i = 0
		
loop_copy_str:
		lb 			$t0, 0($a0)		# $t1 = buffer[i]
		sb 			$t0, 0($a1)			# *(dir + i) = buffer[i]
		beq			$t0, $0, _loop_copy_str  # si se copió '\0' el string se copió completamente
		addi 		$a0, $a0, 1		# i++  buffer
		addi		$a1, $a1, 1		# i++  dir
		addi 		$v0, $v0, 1		# i++
		j 			loop_copy_str
_loop_copy_str:
		jr 			$ra



end:
		