// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Desert Theme
/// @notice Colors, font and names for Desert themed Speedtracer tracks
contract DesertThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0xfcf3cc;
    uint24 public constant KERB_COLOR = 0xaf7c54;
    uint24 public constant ROAD_COLOR = 0xd6b484;
    uint24 public constant MIDLINE_COLOR = 0xe9c9a1;

    // Teko?
    string public constant FONT =
        "url(data:font/woff2;base64,d09GMgABAAAAAB5oAA8AAAAAR5AAAB4KAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGiIbHhyCFgZgP1NUQVQuAIRyEQgK71jVMwuDPgABNgIkA4Z4BCAFhFwHhEIboDczA8HGgYAAfTNEUa43TfJfJ3BzYPNoJUooER5LNKtZrYUoiqNE1ybVA/vO/ee3zdYPKJ5IgUC0SGuEHaOhkcQkCtbQ2UuRHKFDREWujS6RRE3CROmWFSrgP6K5qhKCyXSQECQKBCYhE1QSksmgMgm2bMAXkhVWjGXdYM2TNSWsee6cFWX3BM5g9173DJ43z/dTg5LVfAITGsvuxhNN/K+1lS+7/k4U8XYJq3gKDI0G9zH+f7TWZvh2WxGx+BISJOK+K5AK+U2lInZ3cM6J539NzfdX8mXmPSmlEhCU4QHsrmv1Za3tvVZgWpPoGZB0WvrP60xXPeucykE7xA7jCjh27N5h6vb1v2Lp60sG+cjWoV3SOSSHzlc6xZercykx2EFf2AWksSPghNPUYdrrb37WPd1WZhAJEkSCZPu1/9YW6bLQgWkKPrwtY6vX63qDUoYDRBBrjWBanLEHBjugF/owQKyLwNnhGYuW5JaCExagmQBwjC60GCsVd8gwI0px9aWcqp82Bbi8MFevzeUDf0NB3h2JM7v0kF07sCPWegcPdnRBpMoN/XMHuwH+qZameuCCfs1g+EPQQ6pFO6I3JDyDcfXETG4cdK9faQamojjLy5W8VArLlwsG7285O3vMxeTBwRKjZpGlFZK/dr4eTAYXkwNV2Ywkmjf3MeUdmJXfs549qMtVCazU9509oiIyKK2A0cIK0Km45UfDhxvgf+O1vgAzIS+jbh3u7j6UCRiChbEwQT869QDMC0ebpzHgTBKcipn1oNrYDOa1/dgF01lVA0xo+CVAQHfzWU0wFCmpwbpXL+rVEFd+Pz6XH8wX8kP5Sfws/nGBUIiEPv9MXH97d3x7XY8tWDy6L5/DD1xU4te+2nwAjQ/4P7SxZvxj+AavH/D60mWaDD5vH7y8+vJC1mIAjPFz+CAPDNHcl6z4f+2GbU7pc8dXLrnoGLMNvrbFfv326DXfIj3mmmOhBWabZ7PdPvOYzU6XMThz4cYdmzcfvgIEChKMRyBcBJyUjFyMWHHiJTpio6PuO+i5JEoqaqQ8+QoVKVehUhWa3mQGjZo0a9Wpi5HJdIdccdgDa213y1233TPgumesZrL43AHXvDDoGyutMORbV+3wxDKzHLeLAzssTuw5YnKF8eDJC5cfDn8IXygRMYkQXwoTjaAQJUGkAumSpciUKkOaLDm0KNnKFCtRKpdOvWo1GtR6aJIp2rTrMFWLaYTq7LPXGWedxsBoJsATiDeAtIFcBL3GAPT5COosyNP753WZeH+QJFUok4tICADaZeFjl2s4jKDtOQaPrUIE+mXIAWdqDnPCWo3IqKtIOk4OeANCXJgXrU5TlpOFBeUQEPX9A44hNJcU4mO16ogxZMvQaVLKLPeJuyEz/8wH8sn5a+3nR1o7qoiVdkM3JX/hXB1ctPKe73q9Y3WGER1JeYz7KLBDGu+1M7miM1MWRbTyQaJEDP+qNWGkIwt5hrwFynXjM6FiAiB6zNyZsNfIOXwnNYaCghy06px2OMyFmK9oKNuJywpI6SpD7urlCzEWgHIQJ/lOFFPDK1BQfjjszLaVu9gTSBJ0u+LSVO8B9zkwmWlSY9M0umq4dj0vFD30paLShmJfWTMVqWl2aTPPkf7tIv8wX23hYsasC6vFFMSkkjc9vdCWuZwAhvx5prDlGTN0G70Mwat8gtt+9GHwEIFvUyzG2U/ULSVgxsPsTHtq9dvYi/oXCpZOJTMEKqdz2mZyTOZgyQ7jJoHoUMS81tdLXnEXuKBkI05UFmJu6yRN2RPpFVlzmXDAPlCoU7ROKC5U/lflRVUrBipWyDJVrUHOSjtgqRhENhcj3N90lBBiF5gEVDaXE4VQ1OeBgA1zWc2IogwKK96ugK9aVBSHkSJIE2IJzgkA4g4gs2GigK4J+jcFFR6Ipgd/hWz0UAmnxeRCMy40fzf67qDkYV9pyrZh6hVdzt5CzTuBz6gwsghrXO6Et+AAda4pzLQLiqSsD3SjkwdUZrHI3BMEaYLgc0U7oVFDc8MRxjXDTTc34k+BnFYIGOj0smCJ58NzrBKgukMt2GRVDLvKlZm1yS0nFqoBdyGZposdBuLIccvlLSksWBbWj4e9OXLJiQfmJFncd9pgDUfVxDJHucO9xJCMO6lNajsXHm672xXXLJBOdJwIjWRrwmc/V3NSZNvkB8qIiW0eOiO+4U6PGeJ0/bahqtsWAo4K+8i+znhtb8rmCFdOz+wP4oLAZMh2c8rz98GpwXh2TkIJqLd30GJR5k4mAmL7zm5jZd7RFm8LJyBS2qyNCHLnuAUUxwCAXa8NoLkri71zhUkBGs5O0Cz1JnH2J29aF1ziU48Bp6u3atqas8/vxto8t3dEOxh21NqFnJ0CxamzjnKy8yNOlGhjiWhZkDrQQ3H3Fm4gX1PE1FoIg7aaR1KXbFElrnhehyffSekqW0SXynE7oHPID5nf4R9JmJzptEcLZ1GDclP/ySR1rsCMEJKrHH4C11wZKeoTiLGSF/hB1pgxe5TYmlCm5W6zRYXIbYtqyGHFSZmI3yuIMpW/UmW2KuomnvWcfJQ5ui9VgcUR7GoN4W1KYnX+KcQzarYTRuuyoIuVoIARdIhY7V/3eMAF2tyMbayCrwWdZoLOhl7+lJpjMCri2xT2b26P6a5Y7KLOoHB+M/rL19frd6VRDu73ZAY3N6u3xWrwYncsjSSSKEy3s3q9YBpXX2T5sYBh/s5cfi7VKHQwrwsNZcJ+szo2JsSk6ULgtIZ4DfLMQ6vJWHplaScmVcOeu+hBF5TL2Qm63ASOOISlgQLbtSHZNQDUvCj8zTOGubCz8CBhifySrjxtJVwGBgu2yI7MoVnW985Wku5Sj0KrFdXZK+v7VuixNPJdeW/f+f8HDCz7sAHU4tCH/ysUunef59FGjnvcXOIseCSLRn2wFJ7YXpLrmdVZkNILrWo6sRNXwUkoZ4fSfy7HlPfxyuO/HHaOJ1AfX1O3HzDEEK3eV6h0JS/VsMdOVio7auqmwg6SQIP9xl3V1qg8KlQHBP39NIGixtEqsWbyKDCx0CMMQkyoHLAIz8tqlrVY7A8X+ptk37hV/cjlyz6YSH67JaKO6LZKH/YrlwFiV+T/XbJPAPDl/WCpZ5TyJIeefrw6MZDHmzKA4XysoGKUTOZLTG79rY5yN3XOtIh7TkHxFcn6wUHTUMTKsEZAu83NqIxTh3abIlLVQkuWOMFQNl18WMVYjuO/VaFa5iI0uxVNA4aMerPdidu+dbjVIORFNnMvXYEzI+IL4fNkhd9qkjppkwqroQ0RvBFVqzmBqp/TobH64HK4o+oc/5QeMTTrIWfG3k7bBgog9QC+GruNJ/u25zSc7O5BqgeByL9HU3piB5vHO9o63M7u1JE1qyOTe3VkTWp1OgWgh08fSNs4QSFLWNzNca72bhhNP5UN5l5UDCD/Amu09kU9NTxfDou6FS7BQp3f7TLz3wF4dd3VkiUF/gUQ8pz6jAp4rqsWlYp0U4y9oDa+NepGjKrN2s+05zZXmarctdQwNRBMXaaGnKnnFEQbnyts+B7/9JiYZH8LblM8f9nQj8zshm8b2Bbpuh94+G2AFe4WzIoCyQTCJr2F24g0UogGOox1yIwEZIrChrfrsmv1rVKbIoUUIAtgy5aiAbSJPEXY8I20KFlHNhY+RW5C1pfBOpMOoo0o7ecm6gr1BMrdeiuhhql09aEa8jnJ/FTQ5GXytS/1jgL3Xj58rVmjUcwsQQNIQKYSNryWrjilG5DaiBSSj6wQqaOsVLqPzqR7w7MQJBtpEw3un+mazcRBbAvmpuPSMt4MNsXX9sRP4qHEwsRJqrJqNEVRKfWQgohlxWUZDwtMDa29R/4GU8EjQMYSk6731m2+w9oFF+Gfq/nIzBZQKE2opysW6dbjBZRUGNsy7WKBrjpQOIUSoAH5CsyKeFRSpbUNWFcL+56LkOQKyD95RfKqxcSSoL9JPp/cdR0omoFIJIOxAcUqPxZIxhNv9odFlIl61kheIZ+4kC/I4QjyHQnV/rdwm6JTYcM/1614fwoNsNNAQbQ0K0pjW8Wxsf/viwW7ivPIzD5M3SyHL+37tEvZli/w9233RuxlyqWatg11YFdv5tzzjhT4r2UeX9/FnwQjhj5kRtnECfwQbiMmKQZxva7CPBFoAK3CrIgiour5wq6ETaSIdmqBDgPdSN8yUlIKmG/PtthWa48obPjRQrFHu5ht+Wy/7AYYjIjBChJUFegGsDkXnI3VXcaFXahISTD8ZaQbjHM1Q1lD83TRajWvkGco4MHP6UvSG0p+O75Hk3rTZysma4fJ4QZ4Zy1bfkFfXllUqX/RqxvTAWGigqmbWr1tWC+mxBQseE8flw5GioPTxSpWAHsCE6EBZO2h9zum0z7v6T2YFYmwf7y5LKU4PVgcOYiDg2heX2qVAKoEyhJpXn8BVxbMWHIOXSkdjCS52sLChKB8hU16jj6CzEg+0+DqNyxlWzBJVSxuI/ICEztrEwM0kYP4Z7eyfs+CERZ9ApfEn87y8/7HZsWq5tF72jcUYRNsPksLoKDUx42m7dNoWNATKErwo6IIGx4vtRHxVCAaaFTHNMWCqLjx8JmVIzFVStymiKOCkBUWfKdqPy2LP3+9P72LTrO33uzvx0rPWEqP0tDTyzdV/mRVAhk8c9vpPciM+GTCDGZ6gaQyFh/cJRnEttD3lH8rYYHBdhxBx/u8K8nOV4C6PGWoQKgZ/Lho3oyJq3y/2vjXuE2RSPF0EWzfrPixsnhYHx1Dq/HVq86N2ClZTX1DQQiL7sOseujHIdIvtKq3OY1H4mnVBYofJdcga1UyfYiZQsP9rVUxOh/miixYETKjUIK/mwnS5xF+Dzx5aAe7B1nRuA7w48Sg3IqrOB/kQRh6hEKwx0hM2PDGpJKhV+OgpBfZol8wS5OyrqV30XpK6fRVNVU/65cHF/VObu7dnXw1uKbXcKaqYwqjC/9d91pMTWNNZc1AruGK/eVCXkv8ggcdtDaUkYhtYczhtp9dtOcufec/dZ7/6NtG6/6V5JDbg5ysO0qnOnQf1OUHmZHYq5kTQ2O3kC+Sy26w9MKsB6nfE/i45zu2mR1MJigGpeOVSYYqEz6oSCVFbItR/n3VB+kgkWjrIvfakBUFkHHEID4TltBLDo9v41T9P3X4yH7mz8z6Owvy18bjg4o2QmAzok0xWE5L2JOSBB62REliT050MvZ3z1jIfN8FnpyVQ5voJJf63T4jd2fZNUjid6UjXZKyunlno6MF4nTKh1XmI6EC8kf/0BJ0AJ/XFyEzO1oxiDdJbQQ1xeSVoVGLgwZQKZQeQwxKJ+M2Ipuw4URVKGbFOGwLrEn6yjtwaF6GwoZ/t6uYslGQ8V63xzqkEYacdxTpxGFV4851u3VD5SKefKCXGFlOiBihFwGVm23i1nXmzAfVI+k7MnbQVSM9ZwPcGSkbqrsTu45wd6X7XcroT+tvS+mHp59mfarVHtUcren+f9dYXdqe1D014Diip7Znbdc1+u6YEpWiDfc5Hr1dAewR7Z/aXWT1sQq9k9ZJC3n0KD2YG1vVCb2ROd4/7JEaKor6tSWHzoF1MUWGZsQxP5HSKymz+GMCke8Mf4Ll7e8b4r7MbY1XapidLOXhnpROt+XuIW797myW3L/RVywY58G+lQfKvt3uHnKecIx/dDAnpZA3LhQRyH1ZzssDKUf5Y0K5nOfevbbArds9iJAJx3mlsOzPrciK8bQJhA0/yk0Wi9O4+3AbkaQVYANoI2bFRGoRNjCtfSMyI742cfDu46b5krlH7WnaEGRBW9MiRd6rgEX36jErCmdbMCvbzG7RLlbY8Ke4TVHX+io7dd10tB91FcLnZGdmG3LOmemn/9l7szytHBa4HiXpneRK4jP8pgS7p3hooPPSYWRGPCoxWmckUMHI0tFRXc34w9YH1AYrjNQMSqsz6QCMOX/mcBKOJOovG+GTYRcyszu1Kwmb9BLP42RbOi8exqzYpNhAR2cNGuAIezvMcK2h23uovoztVlTwPx5R6AuMNrruQmFsC7YVmdk52hwP1hYOQwNgcm2kp+GDivLWTtMlf4mWOp2kvDXbeZ4HRZFlwFfLxx09iA5bB2Gj3xxOh+MwioH954hjWwBZSzF2TClUGOWZ8vXG0ufGUofK1EpNZXSKkrOMmxXQzRFwlt3KXdgYfZzQb1pf7Y1cylyQswHClcRV4ivZpF8yujlUZ9q5tCg+BuRkKWFOyalQGCVNTeZs45LcZZxKj/Vnz+zxqOEsGwtv4ySn4i4GZx+XMhcN2Hlynku5c5a3Ix9ng+cn4irxpay+kvWyO1PPpVaLv+QhR+CpQRsVnazkdAeo1W/b2bw+e/U+nMuXf/KHYDhyQijOEQtPXNq1Axa9d+H6arjOswQsI4RHpOS81CentiMjzMmT5j7Oi4igWDtAuNzZxY8M/+P9RghGdDfKDDF+Viw+i4s/04HXPscwZ/K+U+DNNmRm3eVDTHdHd3l3OyDWEhTGDq9DOe6PS0UUKzY0eFuMhqJw2Fg4xVjU/6V6o9rpy8JOItLEJjXwS78HAuYswyz4un2f1y4k1qRFnZRcDDsVlZYpRrsa3fWOi3LdRP5henetrkxyMipZI8BOwJTZDJzSu7PRzdV7tMlzdJVoF1z66Y6ys1Q7MzVHGDha0WlO3uXFB24iX5Bw99ifce3qkuqYf7DXSEYWRykkHxMapJgGkzYkjUkUUcWkDL2GkpN/epEcSCAZS5oq9dJ4SacmfJQI/l4l9k9MdYm6HSbfpTZT17S68zoRtZMC1395UpuohpCRoN288sgZD9pfdHnm3mAmlXO2NSxt4GxNqmDeyPHsan/+EJ7866GNKibNuYESKzhbJ9qWWI5u5K774gHsaJrRf8xQ072ju699en9G7cwdM/vgEzOOMPKjNZkESp/Wa8pDHZrgT1ddZh2IjCVvS5a/sQhWKfVd3maHSxP4txky/mP2CaoAI73DSBqFxamcJ7vEuy4yVr2tAoaw1id7SKGS1OE2RT1hw6vFXtjCzuyff+DkYVZ0ClmwRdlr8V+JL/PvSbPf9f6OBu2tM7xiZGZHYgNIx1a9fw+j5REWWYDf+4awYs4QboUhC7vyCsoAvFpMptXIj+ND+HH5yshBPA0flG+IjiC5ATJLROnB/iJ7EDbOXssew/muQOyPFdUVEP1Jt3vpp7oisKs0XR8xpya14Hp+beqUV59eHTGvNjP/ekFNJillXcep+I/+unQq3b/uP/Gn4v7DrRs+Ja7u47VT3MKwsOU4LZ0ZdlIyU0rjyyWhhf6oD+HYMbTZy4zhqB9U3CkRx4lK4njEFNzCU5aS9bXYLETBaIEBFME2w9/G9V1jgWHcRqQX/1W86881L8zxFUX7qZR4K67UNNr3qFWKiuZ99aA+OOJroUT0rSx4+NbIvhdJhO8juOMa5OmVyi3jF4fyCl2KxKrpcY4OXBXXAV5fJ7jIgtHIjNSKQbwZH1TUEDY8khYhM1uCBlARsiJlNqNIKiZKx6X+YYHG0rMUNmmT1EYhSGU4HnHIKkZmpIq+B3kyEQHlhoKEgr0q5e9K35rUyymXa7O0XxLb1VF9X5Gwd94sYEG8QlCkatiMXmDzgeBo0HHELyufbfH9TPVONTxN+U65YLDZzy1vKO+B/LB6yUWB7J64XnQvVeC95pR7onrxPenJ/8ZwPPwPcT04MX4e3EP+Hkz/vrKyvh/WXXw87nbhh4DM0j54qytvKHdjl7hjwcyxE7OrKXCFy0sql9ybR0wrgRpCLaCw170SkZ4kbKlSL1SXqrvVMxYoS5XfBpUtv6CryC7P1r2Z8zUf2D21t76m1r3m+Lih4lvhUc94Dnuvl7xEGdoqC+Ed5ZFctBCLLM0MnSMDDju7NfvdMF1JP6Qr6L7MHtie25rbcm4rBopE77LClm59y6wiWLrOr/YuLxJo2Ec3bFynM+rmjZHjJPgKagH1D7sxrPvFWyfwh/hyqCZcGa4JvRymxnF1i2bTqJKow2hYograz+Xuw1ZgvoAYrMy3ssVzv9dK5IP1e+Hd92M+aGVHeI7ImA2+cv6rzqQhsF7bqn23lf6RXtZEtVIQNn08ldVEZ9Aw3WGJ8ts+KxGWhRPpikSNhP0W0h1qFyuVGYELlfDTlQ2QVzQnNMs9C5KLMBEKywwVimT0QYShmWFozNFzBSbAVnjqjxWcffyUZ90xP8983xCu1Nk36qyr60xPjzy/kE8ycAgFBgA4whAIYKXhfTrxM8eynv08jelgy95jwvOJs/BS30YIvlcjc5lL6XvyGHT39ry/271s1PU97+525y9ovsFuE1+4fcu2u7bwvm5f3qDx+nD9qQuyeaFbUPbR9TsvcAv4S5qgieujW85L3PKyf7v+zcvdcv72tvHHDElrHGAoEEpExvcw8wxDVRLUEHIelwNe/uDje/UaeFXXJ9d40hgKaGU8HUVXEno8eyf7jOenoNHsesXro0NcSD3xP7h+5PVl+pyz6PpqmG+NDvlnu4bLWvW3ID5Crgu8KTqE4H0QvMAE05/bAc6DwXduDu9u/RB58AH81gVzYHgi7biBnGvx0RdU4zW3vLP/kzfqlJZJDMhiD0joKoIQuiwK4bCISwn7A0/zDP7CE+UXC81zwX3SQj3SUgTscGrkPT/cQgAF7HIygszAoocJQmuX16qeeq8iiNacGsySqM8JYmUuCjbqZGRUBMhSDzkmkZnQMucQgV9FF0RoGLSVGQTEIkQgsegFPLS4BwTgw0IIh/lrnZoZyec3Nwc/7ZaU6XV7vPoFnpOmek6MvngzMjExfOnD6/s/BlDg6b6yszanfHOysxsFvP7+18ML/02buN+oa/eSAx0wAQJetB2prw7u/hVgYOVldQdOp4dbqbjq7DJ5n5jMIp96p7hUiLEkmSQENLzms0sune9T9tHxvpYinnkGT+zPk88jC0mRQShWj/SnryCvGLFMwJYghWeDKMucIwawOrNVaOLYpydyxWsoZPft7KueS6ZjpUWmTuSUZqEQcltByeA2iC1p6oSCYJCzpCwCvkYSKixjosyum284REe+JkuH6KcRIurIPADch4fmXzHUvdIKQV5CY0UxCVND9KDSwkeHZrZwsRfSA4xlagm8ZJ9Wn94h9haCtOOXKGKlYhXPw8qZd4LqycU8MotDOgP8/R/3vJJjMds4HIf1C++IgK9ZoQZB0fLPUnKZkFk8fhXcqQ1cK563Jzw94mHJO1wGqDHzeUVb8rKayiF8maVwMb4SlcwHwbX054Qp5w1skbydcbjkIP8kI2jyFyD9OfriJY2Uxgnkk038kp+FgBBE04qJk4Tf3WECuq9e6HOhdVmuu+Lo9cXUVbIsEJc/KbKbMAfElolD1vG79ub3ku5jsV58787c87v4coPU7Dw/a5k5KEgsG2EuR63ZONVjmdv51exTSXLIDIYlkAGZMA1yoYVp+vzhGMBLlZzkc3hssrIO1pmJHUY7ZwBPoi3HMngnZiyTR0LH2onzYSyLmG2svVaTxjoQyhjjIYZbhAGznYOtDFo0aTZN0MzfJYncPlUDkxaLTit9kabSdv1yO5k0kSugkauUQZtOuY0smWIGotMDtH5Gyw1marCzTlPwRYlEjDMna9Jomk7a7rLrECIlivR2AGsygxmWhWsSP7OiKETDnCwSlJDR0Qjxoep+cvnzRfCdHcQomvHsJh+H08iexVRvo4BZcrrcZYyv1ARDK9gLmXRqZdbgp5mErwLrPF/1fJIrok+ds+4xFalJizs23ST2N+jUwZrOZKxJ+xYa2ZQrR+WQUpPhmIZjbXaK8nG9BEZY76H7JjmhwUkhQk0WRsLggUce++mtJx+PzWc+9wWZSHIEhUZRTvvSV5p8Y4NTot+csr/fJPjWkGZPJEp6mwf88n9DlhZt2u3VaooOahqdSE9pdTGZyuhnlGwr5Mg1zQzdpsuTr0ChIjMVm2WOuc6YbZ95SpQqU67CmErzLdRjgSo0Hb1fDah2w0277BaAw08gb1z+fPlgG/Rv/wkT/hs7Bothz3BgODKcwC7O4C7dMkE8WbAc4ABzm9B+wZBzzvKKCyjVqJMmgys3x5hdc529u8674KJL7nDhTKTWqFV6LbfSUqvjCotd5WiJrTLVuxw34BPgOWjcB048bIo7rPHGM2upvPDa83g4Tj/TEicIZaJ2RzdFMVXFrH9SSp0tJWpakxWpqNZkEo5rXclGFutD5sl+cJQi1i0erVT95nLVcRePUqoAAAA=) format('woff2')";

    string[] private prefixes = [
        "New",
        "Historic",
        "Prince of",
        "King of",
        "",
        "Princess of",
        "Queen of",
        "Royal",
        "Grand",
        "",
        "International",
        "Global",
        "",
        "Classic",
        "National",
        ""
    ];
    string[] private cities = [
        "Bahrain",
        "Baku",
        "Abu Dhabi",
        "Lusail",
        "Jeddah",
        "Yas Marina",
        "Ain-Diab",
        "Cairo",
        "Riyadh",
        "Dubai",
        "Doha",
        "Muscat",
        "Amman"
    ];
    string[] private suffixes = [
        "Circuit",
        "Street Circuit",
        "City Circuit",
        "Track",
        "Raceway",
        "Park",
        "Motorway",
        "Speedway",
        "Motorplex",
        "Motorpark",
        "Motor Sport Park",
        "Racecourse",
        "Racing Circuit",
        "TT Circuit",
        "Street Race",
        "Raceway Park"
    ];

    function themeName() external pure returns (string memory) {
        return "Desert";
    }

    function name(uint256 tokenId) external view returns (string memory) {
        uint256 prefixIndex = tokenId % prefixes.length;
        uint256 cityIndex = tokenId % cities.length;
        uint256 suffixIndex = tokenId % suffixes.length;
        return string(
            abi.encodePacked(
                prefixes[prefixIndex],
                " ",
                cities[cityIndex],
                " ",
                suffixes[suffixIndex]
            )
        );
    }

    function background() external pure returns (string memory) {
        return
        '<rect width="1200" height="1950" style="stroke:#af7c54; stroke-width:36;" fill="#fcf3cc" filter="url(#sandTexture)" />';
    }

    function road() external pure returns (string memory) {
        return toHexString(ROAD_COLOR);
    }

    function kerb() external pure returns (string memory) {
        return toHexString(KERB_COLOR);
    }

    function midline() external pure returns (string memory) {
        return toHexString(MIDLINE_COLOR);
    }

    function font() external pure returns (string memory) {
        return FONT;
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 6; ++i) {
            buffer[5 - i] = SYMBOLS[value & 0xF];
            value >>= 4;
        }
        return string(buffer);
    }

    function filter(uint256) external pure returns (string memory) {
        return
        '<filter id="noise" filterUnits="userSpaceOnUse"><feTurbulence type="fractalNoise" baseFrequency="0.25" numOctaves="20" result="noise"/><feComposite in="SourceGraphic" in2="noise" operator="in"/></filter><filter id="tf" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2 2" result="shadow"/><feOffset dx="4" dy="4"/></filter> <filter id="sandTexture" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="2" result="noise" /><feDiffuseLighting in="noise" lighting-color="white" surfaceScale="1" result="diffuseLighting"><feDistantLight azimuth="45" elevation="55" /></feDiffuseLighting><feBlend in="SourceGraphic" in2="diffuseLighting" mode="multiply" /></filter>';
    }
}
