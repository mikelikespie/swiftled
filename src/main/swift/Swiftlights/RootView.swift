import Views
import RxSwift
import Fixtures

class RootView : YogaScrollView {
    
    let disposeBag = DisposeBag()

    
    let fixtureConfiguration: Observable<FixtureConfiguration>
    
    init(fixtureConfiguration: Observable<FixtureConfiguration>, layoutDirtier: LayoutDirtier) {
        self.fixtureConfiguration = fixtureConfiguration
        
        super.init(frame: .zero)
        
        fixtureConfiguration
            .subscribe(onNext: { [weak self] config in
                guard let `self` = self else {
                    return
                }
                
                self.cells = config
                    .fixtures
                    .map { FixtureProfileView(fixture: $0.fixture, profile: $0.fixture.profiles[0]) }
            })
            
            .disposed(by: disposeBag)
        
        layoutDirtier
            .observable
            .subscribe(onNext: { [weak self] config in
                self?.container.setNeedsLayout()
            })
            .disposed(by: disposeBag)
    }
    
    
}
