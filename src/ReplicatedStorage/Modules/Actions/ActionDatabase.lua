local ActionDatabase = {

	BasicJump = {

		Id = "BasicJump",

		Name = "Salto",
		
		Category = "Attack",

		Slot = "Basic",

		Description = "Salta sobre un enemigo, no nos demanden porfis",

		QTE = "JumpBasic",

		AttackType  = "Basic",

		TargetType = "SingleEnemy",

		CanAttackFlying = true,
	},
	
	Stick = {

		Id = "Stick",

		Name = "Rama",
		
		Category = "Attack",

		Slot = "Tool",

		Description = "No subestimes a las ramas, ¿alguna vez te golpearon con una?, si lo hubieran hecho no menospreciarias esta arma...",

		QTE = "SwordBasic",

		AttackType  = "Tool",

		TargetType = "SingleEnemy",

	},
	
	SlingShot = {

		Id = "SlingShot",

		Name = "Resortera",

		Category = "Attack",

		Slot = "Ranged",

		Description = "Una arma infaltable en el arsenal de cualquier niño, su desempeño en combate es cuestionable, pero la municion es tan cara como recoger piedras del suelo",

		QTE = "SlingShotBasic",

		AttackType  = "Ranged",

		TargetType = "SingleEnemy",

	}

}	

function ActionDatabase.Get(id)
	return ActionDatabase[id]
end

return ActionDatabase