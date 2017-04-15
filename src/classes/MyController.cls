public class MyController {

	public List<CarWrapper> items {get;set;}
	public Integer itemsSize {get;set;}

	public MyController() {
		items = new List<CarWrapper>();
		CarWrapper cw = new CarWrapper(this);
		items.add(cw);
		itemsSize = items.size();
		System.debug('Size ' +itemsSize);
	}

	public PageReference addNew(){
		if(items != null){
			CarWrapper cw = new CarWrapper(this);
			items.add(cw);
		}
		itemsSize = items.size();
		System.debug('Size ' +itemsSize);
		return null;
	}

	public PageReference deleteRow(){
		if(itemsSize >= 1){
			items.remove(itemsSize - 1);
			itemsSize = items.size();
		}
		return null;
}

	public PageReference updateRow(){
		String selectedCarId;
		for(CarWrapper carwrp:items){
			if(String.isNotBlank(carwrp.selectedCarId)){
				selectedCarId = carwrp.selectedCarId;
				carwrp.brands = carwrp.getBrandSelectOptions(selectedCarId);
				carwrp.types = carwrp.getTypesSelectOptions(selectedCarId);
				carwrp.years = carwrp.getYearsSelectOptions(selectedCarId);
			}else{
				carwrp.cars =  carwrp.getCarsSelectOptions();
			}
		}
		itemsSize = items.size();
		return null;
	}

	public class CarWrapper{

		public String selectedCarId{get; set;}
		public String selectedBrandId{get; set;}
		public String selectedTypeId{get; set;}
		public String selectedYeardId{get; set;}

		public List<SelectOption> cars {get; set;}
		public List<SelectOption> brands{get; set;}
		public List<SelectOption> types{get; set;}
		public List<SelectOption> years{get; set;}

		Map<Id, List<Brand__c>> carBrandMap = new Map<Id, List<Brand__c>>();

		MyController outerCls;

		public CarWrapper(MyController outerCls){
			this.outerCls = outerCls;
			this.cars = getCarsSelectOptions();
			this.brands = new list<selectoption> { new selectoption('','Select one') };
			this.types = new list<selectoption> { new selectoption('','Select one') };
			this.years = new list<selectoption> { new selectoption('','Select one') };
		}

		public List<SelectOption> getCarsSelectOptions(){
			List<selectoption> s = new list<selectoption> ();
			s.add(new selectoption('','Select one'));
			Boolean carPresent = false;
			for(Car__c car: [SELECT Id, Name FROM Car__c]){
				carPresent = false;
				for(CarWrapper carwrp:outerCls.items){
					if(carwrp!=null && carwrp.selectedCarId==car.Id){
						carPresent = true;
					}
				}
				if(!carPresent){
					s.add(new selectoption(car.Id, car.Name));
				}
			}
			return s;
		}
		public List<SelectOption> getBrandSelectOptions(String carId){
			List<Brand__c> lstBrand = new List<Brand__c>();

			List<selectoption> s = new list<selectoption> ();
			s.add(new selectoption('','Select one'));

			if(carBrandMap.containsKey(carId)){
				lstBrand = carBrandMap.get(carId);
			}else{
				lstBrand = [SELECT Id, Name FROM Brand__c WHERE Car__c=: carId];
				carBrandMap.put(carId,lstBrand);
			}

			for(Brand__c brand: lstBrand){
				s.add(new selectoption(brand.Id, brand.Name));
			}
			return s;
		}

		public List<SelectOption> getTypesSelectOptions(String carId){
			List<selectoption> s = new list<selectoption> ();
			s.add(new selectoption('','Select one'));

			for(Type__c type: [SELECT Id, Name FROM Type__c WHERE Car__c=: carId]){
				s.add(new selectoption(type.Id, type.Name));
			}
			return s;
		}

		public List<SelectOption> getYearsSelectOptions(String carId){
			List<selectoption> s = new list<selectoption> ();
			s.add(new selectoption('','Select one'));

			for(Year__c year: [SELECT Id, Name FROM Year__c WHERE Car__c=: carId]){
				s.add(new selectoption(year.Id, year.Name));
			}
			return s;
		}
	}
}