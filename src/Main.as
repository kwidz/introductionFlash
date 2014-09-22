package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author kwidz
	 */
	public class Main extends Sprite 
	{
		public var txtAjouter:TextField = new TextField();
		public var txtDeplacer:TextField = new TextField();
		
		private var tabCarre:Array = new Array(); //tableau pour faire la gestion des carrés, je vais m'organiser pour qu'il soit ordonné
		                                         //de sorte à ce que le premier carré soit toujours le plus haut à la gauche et le dernier 
												 //le plus bas à la droite.
		private var down:Boolean = true;
		
		public function Main():void 
		{
			if (stage)
			{
				init();
				stage.addEventListener(Event.RESIZE,redimensionement);
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
				
			}
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//ajout des écouteurs sur les boutons qui sont en fait des champs texte.
			txtAjouter.addEventListener(MouseEvent.CLICK, txtAjouterMouseClickHandler);
			txtDeplacer.addEventListener(MouseEvent.CLICK, txtDeplacerMouseClickHandler);
		}
		
		private function txtDeplacerMouseClickHandler(e:MouseEvent):void 
		{
			var carreTemp:CarreNoir;
	
			verifierDirection();//méthode qui va déterminer si les carrés montent ou descendent
			
			for each (carreTemp in tabCarre) //utilisation d'un for each pour déplacer tous les carrés
			{
				if (down)
					carreTemp.y += 10;
				else
					carreTemp.y -= 10;
			}
		}
		
		private function verifierDirection():void
		{
			if (tabCarre.length != 0)
			{
				if (down)
				{
					var dernier:CarreNoir = CarreNoir(tabCarre[tabCarre.length - 1]);
					
					if (dernier.y + dernier.height + 10 >= txtAjouter.y)//si on rajoute 10 pixels vers le bas au dernier carré et que l'on embarque sur les boutons
						down = false;
				}
				else
				{
					var premier:CarreNoir = CarreNoir(tabCarre[0])
					
					if (premier.y - 10 <= 0)//si on remonte de 10 pixels le premier carré et que l'on commence à disparaître de l'céran
						down = true;
				}
			}	
		}
		
		private function txtAjouterMouseClickHandler(e:MouseEvent):void 
		{
			if (tabCarre.length != 10) //s'il n'y a pas déjà 10 carrés à l'écran
			{
				var carre:CarreNoir = new CarreNoir();
				var nombreCarres:uint = tabCarre.length;
				
				if (tabCarre.length == 0) //si c'est le premier carré que nous plaçons
				{
					carre.x = 10;
					carre.y = 10;
				}
				else
				{
					var dernier:CarreNoir = tabCarre[tabCarre.length - 1];
					
					if (dernier.x + (dernier.width * 2) + 10 >= stage.stageWidth) //on vérifie s'il y a de la place à la droite du dernier carré
					{
						carre.y = dernier.y + 10 + dernier.height; //s'il n'y en a pas, on place le carré au début de la prochaine ligne
						carre.x = 10;
					}
					else
					{  //s'il y a de la place, on le place à la droite du dernier carré
						carre.x = dernier.x + dernier.width + 10;
						carre.y = dernier.y;
					}
					
					if (carre.y + carre.height + 10 >= txtAjouter.y) //si nous avons placé le carré sur un des boutons
						gestionCarreDepasseBouton(carre);
				}
				
				carre.addEventListener(MouseEvent.CLICK, carreMouseClickHandler);
				
				stage.addChild(carre);
				
				if (tabCarre.length == nombreCarres) //si la méthode gestionCarreDepasseBouton n'a pas déjà placé le carré dans le tableau
					tabCarre.push(carre);
			}
			else
			{
				trace("il y a deja 10 carres a l'ecran !!");
			}
		}
		
		private function gestionCarreDepasseBouton(carre:CarreNoir):void
		{
			var ajouter:Boolean = false;
			var limite:uint = tabCarre.length - 1;
			var carreBidon:CarreNoir;
			var indice:uint;
			var placerNouvelleLigne:Boolean = false;
			
			for (var i:uint = 0; i < limite; i++)
			{
				carreBidon = CarreNoir(tabCarre[i]);
				
				if (carreBidon.x + carreBidon.width + 10 != CarreNoir(tabCarre[i + 1]).x && carreBidon.x + (carreBidon.width * 2) + 10 < stage.stageWidth)// && carreBidon.y == CarreNoir(tabCarre[i + 1]).y)
				{  	//il y a de la place à la droite du carré que l'on analyse
					ajouter = true;
					
					carre.x = carreBidon.x + carreBidon.width + 10;
					carre.y = carreBidon.y;
					
					indice = i + 1;
					
					i = limite;
					
				} //les deux prochaines conditions nous amènent à rajouter une nouvelle ligne
				else if (CarreNoir(tabCarre[i + 1]).y != carreBidon.y && CarreNoir(tabCarre[i + 1]).x != 10)
				{
					placerNouvelleLigne = true;
				}
				else if (CarreNoir(tabCarre[i + 1]).y > carreBidon.y + carreBidon.height + 10)
				{
					placerNouvelleLigne = true;
				}
				
				if (placerNouvelleLigne) 
				{
					ajouter = true;
					
					carre.x = 10;
					carre.y = carreBidon.y + carreBidon.height + 10;
					
					indice = i + 1;
					
					i = limite;
				}
			}
		
			if (ajouter) //si le carré à été positionné
			{
				tabCarre.splice(indice, 0, carre); //on insère notre carré au bon endroit dans le tableau
			}
			else
			{
				carre.x = 10;
				carre.y = CarreNoir(tabCarre[0]).y - 10 - carre.height;
				tabCarre.unshift(carre); 
			}
		}
		
		private function carreMouseClickHandler(e:MouseEvent):void 
		{
			var indice:int = 0;
			var carrePusBon:CarreNoir = CarreNoir(e.target);
			
			indice = tabCarre.indexOf(carrePusBon);
			
			carrePusBon.removeEventListener(MouseEvent.CLICK, carreMouseClickHandler);
			
			stage.removeChild(carrePusBon);
					
			tabCarre.splice(indice, 1);
		}
		
		private function redimensionement(e:Event):void {
				
				stage.align = StageAlign.TOP_LEFT;
				trace("redimentionnement !");				
				}
	}
}